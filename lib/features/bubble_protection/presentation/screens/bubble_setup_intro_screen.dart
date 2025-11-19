import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/theme/color_schemes.dart';
import '../../../../core/widgets/widgets.dart';
import 'bubble_setup_permission_screen.dart';

class BubbleSetupIntroScreen extends StatelessWidget {
  const BubbleSetupIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header with icon, title, and subtitle
                    OnboardingStyleHeader(
                      icon: Icons.bubble_chart_rounded,
                      title: 'bubble.setup.intro.title'.tr(),
                      subtitle: 'bubble.setup.intro.subtitle'.tr(),
                    ),
                    const SizedBox(height: 32),

                    // Privacy feature cards
                    FeatureCard(
                      icon: Icons.lock_outline,
                      text: 'bubble.setup.intro.privacy.secure.title'.tr(),
                    ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      icon: Icons.cloud_off_outlined,
                      text: 'bubble.setup.intro.privacy.noData.title'.tr(),
                    ),
                    const SizedBox(height: 12),
                    FeatureCard(
                      icon: Icons.shield_outlined,
                      text: 'bubble.setup.intro.privacy.privacy.title'.tr(),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BubbleSetupPermissionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'button.continue'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
