import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../widgets/onboarding_button.dart';

/// Done screen - Step 5 of onboarding
class DoneScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const DoneScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  State<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Done icon
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 42,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'onboarding.done.title'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'onboarding.done.description'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Features
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildFeatureCard(
                    Icons.touch_app_outlined,
                    'onboarding.done.features.scan.title'.tr(),
                    'onboarding.done.features.scan.description'.tr(),
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    Icons.link_outlined,
                    'onboarding.done.features.links.title'.tr(),
                    'onboarding.done.features.links.description'.tr(),
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    Icons.flag_outlined,
                    'onboarding.done.features.report.title'.tr(),
                    'onboarding.done.features.report.description'.tr(),
                    Colors.green,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Done button
            OnboardingButton(
              text: 'button.getStarted'.tr(),
              onPressed: widget.onGetStarted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Feature icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          // Feature text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
