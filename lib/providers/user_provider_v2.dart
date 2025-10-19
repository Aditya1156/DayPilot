import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daypilot/services/firebase_service.dart';
import 'package:daypilot/models/user_profile.dart';

// Check if Firebase is initialized
bool _isFirebaseInitialized() {
  try {
    Firebase.app();
    return true;
  } catch (e) {
    return false;
  }
}

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  if (!_isFirebaseInitialized()) {
    return Stream.value(null);
  }
  return FirebaseAuth.instance.authStateChanges();
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  if (!_isFirebaseInitialized()) {
    return null;
  }
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

// User profile provider (from Firestore or SharedPreferences)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final firebaseService = FirebaseService();
  
  // Try Firebase first
  if (_isFirebaseInitialized()) {
    final user = ref.watch(currentUserProvider);
    if (user != null && firebaseService.isAvailable()) {
      final profile = await firebaseService.getUserProfile(user.uid);
      if (profile != null) return profile;
    }
  }
  
  // Fallback to SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username') ?? 'User';
  final email = prefs.getString('email') ?? '';
  
  return UserProfile(
    uid: 'local',
    email: email,
    username: username,
    createdAt: DateTime.now(),
    lastActive: DateTime.now(),
  );
});

// Username provider with local fallback
final usernameProvider = FutureProvider<String>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  return profile?.username ?? 'User';
});

// User display name provider (synchronous version for UI)
final userDisplayNameProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.username ?? 'User',
    loading: () => 'User',
    error: (_, __) => 'User',
  );
});

// User email provider
final userEmailProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile?.email ?? '',
    loading: () => '',
    error: (_, __) => '',
  );
});

// User photo URL provider
final userPhotoUrlProvider = Provider<String?>((ref) {
  if (!_isFirebaseInitialized()) {
    return null;
  }
  final user = ref.watch(currentUserProvider);
  return user?.photoURL;
});

// Username setup complete provider
final usernameSetupCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('username_setup_complete') ?? false;
});

// Theme mode provider
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

// Notification settings provider
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

// Sound settings provider
final soundEnabledProvider = StateProvider<bool>((ref) => true);
