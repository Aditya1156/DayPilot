import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daypilot/models/user_profile.dart';
import 'package:daypilot/services/firebase_service.dart';

/// Comprehensive user profile provider with Firestore integration
/// Combines Firebase Auth user with Firestore profile data
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _initialize() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      // Try to fetch from Firestore first
      if (_firebaseService.isAvailable()) {
        try {
          final profile = await _firebaseService.getUserProfile(user.uid);
          
          if (profile != null) {
            state = AsyncValue.data(profile);
            // Also save to SharedPreferences for offline access
            await _saveToLocalStorage(profile);
            return;
          }
        } catch (e) {
          print('⚠️ Failed to fetch profile from Firestore: $e');
        }
      }

      // Fallback: Create profile from Firebase Auth user + SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? 
                      user.displayName ?? 
                      user.email?.split('@').first ?? 
                      'User';

      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        username: username,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastActive: DateTime.now(),
      );

      state = AsyncValue.data(profile);

      // Save to Firestore if available
      if (_firebaseService.isAvailable()) {
        try {
          await _firebaseService.saveUserProfile(profile);
        } catch (e) {
          print('⚠️ Failed to save profile to Firestore: $e');
        }
      }
    } catch (e, stack) {
      print('❌ Error initializing user profile: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _saveToLocalStorage(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', profile.username);
      await prefs.setString('email', profile.email);
      if (profile.photoUrl != null) {
        await prefs.setString('photoUrl', profile.photoUrl!);
      }
    } catch (e) {
      print('⚠️ Failed to save to local storage: $e');
    }
  }

  /// Update username in Firestore and local state
  Future<void> updateUsername(String newUsername) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    try {
      // Update Firebase Auth display name
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.updateDisplayName(newUsername);
        } catch (e) {
          print('⚠️ Failed to update Firebase Auth display name: $e');
        }
      }

      // Update Firestore
      if (_firebaseService.isAvailable()) {
        await _firebaseService.updateUsername(currentProfile.uid, newUsername);
      }

      // Update local state
      final updatedProfile = currentProfile.copyWith(
        username: newUsername,
        lastActive: DateTime.now(),
      );
      state = AsyncValue.data(updatedProfile);

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', newUsername);
    } catch (e, stack) {
      print('❌ Error updating username: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update profile photo URL
  Future<void> updatePhotoUrl(String? photoUrl) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    try {
      // Update Firebase Auth photo URL
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.updatePhotoURL(photoUrl);
        } catch (e) {
          print('⚠️ Failed to update Firebase Auth photo URL: $e');
        }
      }

      // Update Firestore
      if (_firebaseService.isAvailable()) {
        await _firebaseService.saveUserProfile(
          currentProfile.copyWith(photoUrl: photoUrl, lastActive: DateTime.now()),
        );
      }

      // Update local state
      final updatedProfile = currentProfile.copyWith(
        photoUrl: photoUrl,
        lastActive: DateTime.now(),
      );
      state = AsyncValue.data(updatedProfile);

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (photoUrl != null) {
        await prefs.setString('photoUrl', photoUrl);
      } else {
        await prefs.remove('photoUrl');
      }
    } catch (e, stack) {
      print('❌ Error updating photo URL: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh profile from Firestore
  Future<void> refresh() async {
    await _initialize();
  }

  /// Update last active timestamp
  Future<void> updateLastActive() async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    try {
      if (_firebaseService.isAvailable()) {
        await _firebaseService.updateLastActive(currentProfile.uid);
      }

      final updatedProfile = currentProfile.copyWith(lastActive: DateTime.now());
      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      // Non-critical, just log
      print('⚠️ Failed to update last active: $e');
    }
  }
}

/// Provider for user profile
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier();
});

/// Convenient provider to get username directly
final usernameProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.username ?? 'User',
    loading: () => 'Loading...',
    error: (_, __) => 'User',
  );
});

/// Convenient provider to get user email directly
final userEmailAddressProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.email ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
});

/// Convenient provider to get photo URL directly
final userPhotoProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.photoUrl,
    loading: () => null,
    error: (_, __) => null,
  );
});
