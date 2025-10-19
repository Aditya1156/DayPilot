import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// User display name provider with SharedPreferences fallback
final userDisplayNameProvider = FutureProvider<String>((ref) async {
  if (!_isFirebaseInitialized()) {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Guest User';
  }
  final user = ref.watch(currentUserProvider);
  
  // Try Firebase user's display name first
  if (user?.displayName != null && user!.displayName!.isNotEmpty) {
    return user.displayName!;
  }
  
  // Try SharedPreferences as fallback
  final prefs = await SharedPreferences.getInstance();
  final savedUsername = prefs.getString('username');
  if (savedUsername != null && savedUsername.isNotEmpty) {
    return savedUsername;
  }
  
  // Last resort: use email or 'User'
  return user?.email?.split('@').first ?? 'User';
});

// User email provider
final userEmailProvider = Provider<String>((ref) {
  if (!_isFirebaseInitialized()) {
    return '';
  }
  final user = ref.watch(currentUserProvider);
  return user?.email ?? '';
});

// User photo URL provider
final userPhotoUrlProvider = Provider<String?>((ref) {
  if (!_isFirebaseInitialized()) {
    return null;
  }
  final user = ref.watch(currentUserProvider);
  return user?.photoURL;
});

// Theme mode provider
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

// Notification settings provider
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

// Sound settings provider
final soundEnabledProvider = StateProvider<bool>((ref) => true);
