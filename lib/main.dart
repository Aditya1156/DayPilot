import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:daypilot/utils/theme.dart';

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

  // Attempt Firebase init. If Firebase options are not configured for the
  // current platform this will print a message and continue — prevents crash
  // during early development when Firebase isn't set up yet.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Safe to continue; backend integration can be added later.
    // Print to help developer notice missing Firebase setup during development.
    // ignore: avoid_print
    print('Firebase initialization skipped or failed: $e');
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      // Register named routes for the main feature pages
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/routines': (context) => const RoutineBuilderScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/ai': (context) => const AIOptimizationScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
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

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    });
  }

  Future<bool> _checkUsernameSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('username_setup_complete') ?? false;
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

    // Check username setup after onboarding
    return FutureBuilder<bool>(
      future: _checkUsernameSetup(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Show username setup if not complete
        if (snapshot.data == false) {
          return const UsernameSetupScreen();
        }

        // Check if Firebase is initialized
        if (!_isFirebaseAvailable()) {
          // Firebase not initialized, go directly to dashboard
          return const DashboardScreen();
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Handle errors
            if (snapshot.hasError) {
              return const DashboardScreen();
            }
            
            // Show loading while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Show login if not authenticated
            if (!snapshot.hasData || snapshot.data == null) {
              return const LoginScreen();
            }
            
            // Show dashboard if authenticated
            return const DashboardScreen();
          },
        );
      },
    );
  }
}