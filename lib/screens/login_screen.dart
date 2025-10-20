import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';
import '../services/firebase_service.dart';
import '../models/user_profile.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = FirebaseAuth.instance;

      // Debug logging
      print('🔐 Auth attempt: ${_isLogin ? "LOGIN" : "SIGNUP"}');
      print('📧 Email: ${_emailController.text.trim()}');

      if (_isLogin) {
        // Login
        print('🔑 Attempting login...');
        User? user;
        try {
          final credential = await auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          user = credential.user;
          print('✅ Login successful! UID: ${user?.uid}');
        } on FirebaseAuthException {
          rethrow;
        } catch (e) {
          if (_isKnownFirebaseAuthPluginBug(e)) {
            print('! Known firebase_auth plugin bug (non-critical): $e');
            print('   Continuing with current user session.');
            user = auth.currentUser;
          } else {
            rethrow;
          }
        }

        // Sync user profile to Firestore (create if missing)
        if (user != null) {
          try {
            final firebaseService = FirebaseService();
            if (firebaseService.isAvailable()) {
              // Check if user profile exists in Firestore
              print('🔍 Checking if Firestore profile exists...');
              final existingProfile =
                  await firebaseService.getUserProfile(user.uid);

              if (existingProfile == null) {
                // Profile missing! Create it now (fixes Auth-only accounts)
                print('⚠️ Firestore profile missing! Creating now...');
                final newProfile = UserProfile(
                  uid: user.uid,
                  email: user.email ?? _emailController.text.trim(),
                  username:
                      user.displayName ?? user.email?.split('@')[0] ?? 'User',
                  createdAt: DateTime.now(),
                  lastActive: DateTime.now(),
                );
                await firebaseService.saveUserProfile(newProfile);
                print('✅ Firestore profile created successfully!');

                // Save to local storage too
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('username', newProfile.username);
                  await prefs.setString('email', newProfile.email);
                  await prefs.setBool('username_setup_complete', true); // Mark setup as complete
                  print('✅ Profile saved to local storage');
                } catch (e) {
                  print('⚠️ Local storage save failed: $e');
                }
              } else {
                // Profile exists, just update last active
                print('✅ Firestore profile exists');
                await firebaseService.updateLastActive(user.uid);
                print('✅ Last active timestamp updated');
                
                // Ensure username setup is marked as complete
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('username_setup_complete', true);
                  print('✅ Username setup marked as complete');
                } catch (e) {
                  print('⚠️ Failed to mark username setup complete: $e');
                }
              }
            }
          } catch (e) {
            print('⚠️ Firestore sync failed (non-critical): $e');
            // Non-critical, continue with login
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Profile sync incomplete. Please check your connection.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        } else {
          print('⚠️ Login succeeded but no active user session detected.');
        }
      } else {
        // Sign up
        print('📝 Attempting signup...');

        // Step 1: Create Firebase Auth user
        User? user;
        try {
          final credential = await auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          user = credential.user;
          print('✅ Signup successful! UID: ${user?.uid}');
        } on FirebaseAuthException {
          rethrow;
        } catch (e) {
          if (_isKnownFirebaseAuthPluginBug(e)) {
            print('! Known firebase_auth plugin bug (non-critical): $e');
            print('   Continuing with current user session.');
            user = auth.currentUser;
          } else {
            rethrow;
          }
        }

        if (user != null) {
          final username = _nameController.text.trim();
          final email = _emailController.text.trim();
          final uid = user.uid;

          print('🔧 Starting post-signup data save process...');

          // Step 2: Save to Firestore IMMEDIATELY (before any other Firebase operations)
          bool firestoreSaved = false;
          try {
            final firebaseService = FirebaseService();
            print(
                '🔧 Firebase service available: ${firebaseService.isAvailable()}');

            if (firebaseService.isAvailable()) {
              print('💾 Saving user profile to Firestore...');
              print('🆔 User UID: $uid');
              print('📧 Email: $email');
              print('👤 Username: $username');

              final userProfile = UserProfile(
                uid: uid,
                email: email,
                username: username,
                createdAt: DateTime.now(),
                lastActive: DateTime.now(),
              );

              print('📄 Profile data: ${userProfile.toFirestore()}');

              await firebaseService.saveUserProfile(userProfile);
              print('✅ User profile saved to Firestore successfully!');
              firestoreSaved = true;
            } else {
              print('❌ Firebase service not available!');
            }
          } catch (firestoreError) {
            print('❌ Firestore save failed: $firestoreError');
            print('📊 Error details: ${firestoreError.runtimeType}');
            if (firestoreError is FirebaseException) {
              print('🔍 Firebase error code: ${firestoreError.code}');
              print('🔍 Firebase error message: ${firestoreError.message}');
            } else {
              print('🔍 Full error: $firestoreError');
            }
          }

          // Step 3: Save to SharedPreferences (local backup)
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', username);
            await prefs.setString('email', email);
            await prefs.setBool('username_setup_complete', true); // Mark setup as complete
            print('✅ User data saved to local storage');
          } catch (e) {
            print('⚠️ Failed to save to local storage: $e');
          }

          // Step 4: Try Firebase Auth operations (these may fail due to plugin bug, but data is already saved)
          try {
            print('👤 Attempting Firebase Auth display name update...');
            await user.updateDisplayName(username);
            print('✅ Firebase Auth display name updated');
          } catch (displayNameError) {
            print(
                '⚠️ Firebase Auth display name update failed (non-critical, known bug in firebase_auth 4.16.0)');
            print('   Error: $displayNameError');
            // This is expected with firebase_auth 4.16.0 - profile data is already saved elsewhere
          }

          try {
            await user.reload();
            print('✅ User reloaded successfully');
          } catch (reloadError) {
            print('⚠️ User reload failed (non-critical): $reloadError');
          }

          // Step 5: Show result message
          if (firestoreSaved) {
            print('🎉 Signup completed successfully with full profile sync!');
          } else {
            print('⚠️ Signup completed, but profile sync incomplete');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Account created! Profile data will sync when connection is restored.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          }
        } else {
          print('❌ Signup reported success but no active user session found.');
        }
      }

      print('🎉 Authentication completed successfully!');
      
      // Force a small delay to ensure auth state and SharedPreferences propagate
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Verify current user state
      final currentUser = FirebaseAuth.instance.currentUser;
      print('🔍 Current user after auth: ${currentUser?.uid ?? 'null'}');
      
      // Navigate to dashboard immediately after successful authentication
      if (mounted && currentUser != null) {
        print('🚀 Navigating to dashboard...');
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      String message = 'Authentication failed';

      switch (e.code) {
        case 'user-not-found':
          message =
              'No account found with this email.\nPlease sign up first or check your email address.';
          break;
        case 'wrong-password':
          message =
              'Incorrect password.\nPlease try again or reset your password.';
          break;
        case 'invalid-credential':
          message =
              'Invalid email or password.\nPlease check your credentials and try again.';
          break;
        case 'email-already-in-use':
          message = 'Email already registered.\nPlease log in instead.';
          break;
        case 'weak-password':
          message = 'Password is too weak.\nUse at least 6 characters.';
          break;
        case 'invalid-email':
          message =
              'Invalid email address format.\nPlease check and try again.';
          break;
        case 'network-request-failed':
          message = 'Network error.\nPlease check your internet connection.';
          break;
        case 'too-many-requests':
          message =
              'Too many failed attempts.\nPlease wait a moment and try again.';
          break;
        default:
          message = 'Authentication error: ${e.code}\n${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Filter out known non-critical firebase_auth plugin bug
      if (_isKnownFirebaseAuthPluginBug(e)) {
        print('⚠️ Known firebase_auth plugin bug (non-critical): $e');
        print(
            '   This error can be safely ignored - authentication succeeded.');
        // Don't show error to user, account was created successfully
      } else {
        // Real error, show to user
        print('❌ General exception during auth: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      print('🔄 Resetting loading state');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    // TODO: Implement Google Sign-In
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In coming soon!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    // Show dialog to enter email
    final emailController = TextEditingController(text: _emailController.text);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a password reset link.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon:
                    const Icon(Icons.email_outlined, color: AppColors.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    if (result == true && emailController.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent! Check your inbox.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Failed to send reset email';

        switch (e.code) {
          case 'user-not-found':
            message = 'No account found with this email address.';
            break;
          case 'invalid-email':
            message = 'Invalid email address format.';
            break;
          case 'too-many-requests':
            message = 'Too many requests. Please wait a moment and try again.';
            break;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _animationController.reset();
      _animationController.forward();
    });
  }

  bool _isKnownFirebaseAuthPluginBug(Object error) {
    final message = error.toString();
    return message.contains('PigeonUserDetails') &&
        message.contains('List<Object?>');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor.withAlpha((0.8 * 255).round()),
              AppColors.secondaryColor.withAlpha((0.8 * 255).round()),
              AppColors.accentColor.withAlpha((0.6 * 255).round()),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      _buildLogo(),

                      const SizedBox(height: 48),

                      // Auth Form Card
                      _buildAuthCard(),

                      const SizedBox(height: 24),

                      // Social Login
                      _buildSocialLogin(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 60,
              color: AppColors.primaryColor,
            ),
            Positioned(
              bottom: 25,
              child: Icon(
                Icons.check_circle,
                size: 30,
                color: AppColors.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
  color: Colors.white.withAlpha((0.95 * 255).round()),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                _isLogin ? 'Welcome Back!' : 'Create Account',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                _isLogin
                    ? 'Sign in to continue your journey'
                    : 'Join us to boost your productivity',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Name field (only for signup)
              if (!_isLogin) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password field
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (!_isLogin && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              // Forgot password (only for login)
              if (_isLogin) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor:
                      AppColors.primaryColor.withAlpha((0.6 * 255).round()),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isLogin ? 'Signing in...' : 'Creating account...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _isLogin ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Toggle auth mode
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Don't have an account? "
                        : 'Already have an account? ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(
                      _isLogin ? 'Sign Up' : 'Sign In',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withAlpha((0.5 * 255).round()))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.8 * 255).round()),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withAlpha((0.5 * 255).round()))),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            icon: Image.asset(
              'assets/icons/google.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, size: 24),
            ),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
