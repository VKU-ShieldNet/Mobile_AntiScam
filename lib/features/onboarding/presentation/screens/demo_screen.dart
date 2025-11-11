import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../app/theme/color_schemes.dart';
import '../widgets/demo_result_dialog.dart';
import '../widgets/onboarding_button.dart';

/// Demo screen - Step 4 of onboarding
class DemoScreen extends StatefulWidget {
  final VoidCallback onDemoCompleted;

  const DemoScreen({
    super.key,
    required this.onDemoCompleted,
  });

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen>
    with SingleTickerProviderStateMixin {
  bool _isDemoScanning = false;
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

  Future<void> _handleDemoScan() async {
    setState(() => _isDemoScanning = true);

    // Simulate AI scanning
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isDemoScanning = false);

    // Hiển thị kết quả demo
    _showDemoResult();
  }

  void _showDemoResult() {
    showDialog(
      context: context,
      builder: (context) => DemoResultDialog(
        onContinue: widget.onDemoCompleted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Demo icon
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
                      AppColors.primary80.withValues(alpha: 0.1),
                      AppColors.primary80.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  size: 42,
                  color: AppColors.primary80,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'onboarding.demo.title'.tr(),
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
                  'onboarding.demo.description'.tr(),
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

            const Spacer(),

            // Demo button
            OnboardingButton(
              text: 'onboarding.demo.button'.tr(),
              onPressed: _handleDemoScan,
              isLoading: _isDemoScanning,
            ),
          ],
        ),
      ),
    );
  }
}
