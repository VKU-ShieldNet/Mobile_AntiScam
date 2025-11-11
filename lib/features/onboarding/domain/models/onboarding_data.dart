import 'package:flutter/material.dart';

/// Data model for onboarding pages
class OnboardingData {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Gradient gradient;
  final int particles;

  OnboardingData({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.gradient,
    this.particles = 3,
  });
}

/// Enum representing onboarding steps
enum OnboardingStep {
  welcome,       // 1. Welcome screen
  howItWorks,    // 2. How it works
  permissions,   // 3. Request permissions
  tryDemo,       // 4. Demo scan
  done,          // 5. Complete
}

/// Data model for each step in new onboarding flow
class OnboardingStepData {
  final OnboardingStep step;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String>? bulletPoints;
  final String? actionButtonText;
  final VoidCallback? onAction;

  const OnboardingStepData({
    required this.step,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.bulletPoints,
    this.actionButtonText,
    this.onAction,
  });
}

