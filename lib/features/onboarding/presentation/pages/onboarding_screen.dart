import 'package:flutter/material.dart';

import '../../../../app/animations/animations.dart';
import '../../../../app/theme/color_schemes.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../home/presentation/home_page.dart';
import '../widgets/step_indicator.dart';
import '../screens/welcome_screen.dart';
import '../screens/security_screen.dart';
import '../screens/features_screen.dart';
import '../screens/ready_screen.dart';

/// Main onboarding screen with 4 steps
/// 1. Welcome - App introduction
/// 2. Security - Privacy & security explanation
/// 3. Features - What the app can do
/// 4. Ready - Ready to start
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigate to next page
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Complete onboarding and navigate to home
  Future<void> _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle animated particles background
          ...List.generate(
            3,
            (i) => AnimatedParticle(
              key: ValueKey('particle_$i'),
              index: i,
              total: 3,
              color: AppColors.primary80.withValues(alpha: 0.03),
            ),
          ),

          // Main content
          Column(
            children: [
              // Modern status bar progress
              SafeArea(
                bottom: false,
                child: StepIndicator(currentStep: _currentPage, totalSteps: 4),
              ),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swipe
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    WelcomeScreen(onContinue: _nextPage),
                    SecurityScreen(onContinue: _nextPage),
                    FeaturesScreen(onContinue: _nextPage),
                    ReadyScreen(onGetStarted: _completeOnboarding),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
