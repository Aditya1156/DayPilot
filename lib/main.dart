import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/services/notification_service.dart';
import 'package:daypilot/screens/login_screen.dart';
import 'package:daypilot/screens/onboarding_screen.dart';
import 'package:daypilot/screens/username_setup_screen.dart';
import 'package:daypilot/screens/dashboard_screen.dart';
import 'package:daypilot/screens/routine_builder_screen.dart';
import 'package:daypilot/screens/ai_optimization_screen.dart';
import 'package:daypilot/screens/reminders_screen.dart';
import 'package:daypilot/screens/analytics_screen.dart';
import 'package:daypilot/screens/chat_assistant_screen.dart';
import 'package:daypilot/screens/achievements_screen.dart';
import 'package:daypilot/screens/social_screen.dart';
import 'package:daypilot/screens/voice_commands_screen.dart';
import 'package:daypilot/screens/settings_screen.dart';
import 'package:daypilot/screens/ai_assistant_screen.dart';
import 'package:daypilot/screens/enhanced_analytics_screen.dart';
import 'package:daypilot/utils/modern_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage (offline support)
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskCategoryAdapter());
  await Hive.openBox<Task>('tasks');
  await Hive.openBox('settings');

  // Initialize notifications
  await NotificationService.initialize();

  // Initialize Firebase with proper options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    print('🔧 Firebase app: ${Firebase.app().name}');
    print('🔧 Firebase project: ${Firebase.app().options.projectId}');
    // Note: setPersistence is web-only. Mobile platforms have persistence enabled by default.
  } catch (e) {
    // Safe to continue; backend integration can be added later.
    // Print to help developer notice missing Firebase setup during development.
    // ignore: avoid_print
    print('❌ Firebase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: DayPilotApp(),
    ),
  );
}

class DayPilotApp extends StatelessWidget {
  const DayPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayPilot',
      debugShowCheckedModeBanner: false,
      theme: ModernTheme.getLightTheme(),
      darkTheme: ModernTheme.getDarkTheme(),
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
      // Register named routes for the main feature pages
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/routines': (context) => const RoutineBuilderScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/ai': (context) => const AIOptimizationScreen(),
        '/ai-assistant': (context) => const AIAssistantScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/analytics-enhanced': (context) => const EnhancedAnalyticsScreen(),
        '/chat': (context) => const ChatAssistantScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/social': (context) => const SocialScreen(),
        '/voice': (context) => const VoiceCommandsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

// Auth Wrapper to handle login state and onboarding
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _onboardingComplete;
  User? _currentUser;
  bool? _usernameSetupComplete;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    // Listen to auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      print('🔄 Auth state changed: ${user?.uid ?? 'null'}');
      if (!mounted) return; // Check if widget is still mounted
      
      if (user != null) {
        // User logged in - add small delay to ensure SharedPreferences is saved
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return; // Check again after async operation
        
        // Check username setup
        await _checkUsernameSetup();
        print('👤 Username setup check complete: $_usernameSetupComplete');
      } else {
        // User logged out - reset username state
        if (mounted) {
          setState(() {
            _usernameSetupComplete = null;
          });
        }
      }
      // Update user state AFTER checking username setup
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        print('✅ Auth state update complete - User: ${user?.uid ?? 'null'}, Setup: $_usernameSetupComplete');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      });
    }
  }

  Future<void> _checkUsernameSetup() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _usernameSetupComplete = prefs.getBool('username_setup_complete') ?? false;
      });
    }
  }

  bool _isFirebaseAvailable() {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking onboarding status
    if (_onboardingComplete == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show onboarding if not complete
    if (!_onboardingComplete!) {
      return const OnboardingScreen();
    }

    // Check if Firebase is initialized
    if (!_isFirebaseAvailable()) {
      // Firebase not initialized, go directly to dashboard
      return const DashboardScreen();
    }

    final user = _currentUser;
    final usernameSetupComplete = _usernameSetupComplete ?? false;

    print('🔐 Auth state: ${user != null ? 'Authenticated (${user.uid})' : 'Not authenticated'}');
    print('👤 Username setup: ${usernameSetupComplete ? 'Complete' : 'Incomplete'}');

    // Show loading while checking username setup for authenticated user
    if (user != null && _usernameSetupComplete == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show username setup if not complete and user is authenticated
    if (!usernameSetupComplete && user != null) {
      print('👤 Showing username setup screen');
      return const UsernameSetupScreen();
    }

    // Show login if not authenticated
    if (user == null) {
      print('👤 Showing login screen');
      return const LoginScreen();
    }

    // Show dashboard if authenticated and username setup is complete
    print('🏠 Showing dashboard for user: ${user.uid}');
    return const DashboardScreen();
  }
}