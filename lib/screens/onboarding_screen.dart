import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding screen for first-time users
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.wb_sunny,
      title: 'Welcome to DayPilot',
      description: 'Your AI-powered companion for managing daily routines and boosting productivity.',
      gradient: [Colors.orange, Colors.deepOrange],
    ),
    OnboardingPage(
      icon: Icons.timeline,
      title: 'Visual Timeline',
      description: 'See your entire day at a glance with our beautiful circular timeline.',
      gradient: [Colors.blue, Colors.purple],
    ),
    OnboardingPage(
      icon: Icons.psychology,
      title: 'AI Optimization',
      description: 'Get smart suggestions to optimize your schedule and improve productivity.',
      gradient: [Colors.purple, Colors.pink],
    ),
    OnboardingPage(
      icon: Icons.track_changes,
      title: 'Track Progress',
      description: 'Monitor your achievements and build better habits with detailed analytics.',
      gradient: [Colors.green, Colors.teal],
    ),
    OnboardingPage(
      icon: Icons.rocket_launch,
      title: 'Ready to Start?',
      description: 'Let\'s begin your journey to a more organized and productive life!',
      gradient: [Colors.indigo, Colors.blue],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _pages[_currentPage].gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              
              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _pages[_currentPage].gradient.first,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    page.icon,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
