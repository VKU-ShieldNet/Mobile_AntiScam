import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../widgets/flow_components.dart';

/// How It Works screen - Step 2 of onboarding
class HowItWorksScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const HowItWorksScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'onboarding.howItWorks.title'.tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),
                FlowStep(
                  number: '01',
                  icon: Icons.touch_app_outlined,
                  title: 'onboarding.howItWorks.steps.1.title'.tr(),
                  description: 'onboarding.howItWorks.steps.1.description'.tr(),
                ),
                const FlowDivider(),
                FlowStep(
                  number: '02',
                  icon: Icons.screenshot_outlined,
                  title: 'onboarding.howItWorks.steps.2.title'.tr(),
                  description: 'onboarding.howItWorks.steps.2.description'.tr(),
                ),
                const FlowDivider(),
                FlowStep(
                  number: '03',
                  icon: Icons.psychology_outlined,
                  title: 'onboarding.howItWorks.steps.3.title'.tr(),
                  description: 'onboarding.howItWorks.steps.3.description'.tr(),
                ),
                const FlowDivider(),
                FlowStep(
                  number: '04',
                  icon: Icons.notifications_outlined,
                  title: 'onboarding.howItWorks.steps.4.title'.tr(),
                  description: 'onboarding.howItWorks.steps.4.description'.tr(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        // How It Works button
        Container(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'button.continue'.tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
