import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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

// User display name provider
final userDisplayNameProvider = Provider<String>((ref) {
  if (!_isFirebaseInitialized()) {
    return 'Guest User';
  }
  final user = ref.watch(currentUserProvider);
  return user?.displayName ?? user?.email?.split('@').first ?? 'User';
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
