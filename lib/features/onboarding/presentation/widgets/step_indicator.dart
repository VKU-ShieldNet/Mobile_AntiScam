import 'package:flutter/material.dart';
import '../../../../app/theme/color_schemes.dart';

/// Reusable step indicator with bouncing dots animation
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              final isCurrent = index == currentStep;

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                tween: Tween<double>(
                  begin: 0.0,
                  end: isCurrent ? 1.0 : 0.0,
                ),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: isCurrent ? 32 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: isActive
                            ? LinearGradient(
                                colors: [
                                  AppColors.primary80,
                                  AppColors.primary60,
                                ],
                              )
                            : null,
                        color: isActive ? null : Colors.grey[300],
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primary80.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
