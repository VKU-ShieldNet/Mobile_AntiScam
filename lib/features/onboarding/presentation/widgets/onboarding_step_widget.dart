import 'package:flutter/material.dart';

import '../../../../app/animations/animations.dart';

/// Widget component for each onboarding page - Modern card-based design
class OnboardingStepWidget extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<FeatureItem>? features;
  final String? actionButtonText;
  final VoidCallback? onAction;
  final bool showLoading;
  final Widget? customContent;

  const OnboardingStepWidget({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.features,
    this.actionButtonText,
    this.onAction,
    this.showLoading = false,
    this.customContent,
  }) : super(key: key);

  @override
  State<OnboardingStepWidget> createState() => _OnboardingStepWidgetState();
}

/// Model cho feature items
class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingStepWidgetState extends State<OnboardingStepWidget>
    with TickerProviderStateMixin {
  late FadeScaleAnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = FadeScaleAnimationController(vsync: this);
    _animationController.start();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController.fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animationController.scaleAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.iconColor.withValues(alpha: 0.1),
                      widget.iconColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  widget.icon,
                  size: 42,
                  color: widget.iconColor,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title - bold and modern
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1.2,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description - refined
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // Custom content if provided
            if (widget.customContent != null) widget.customContent!,

            // Features grid - modern card style
            if (widget.features != null && widget.features!.isNotEmpty)
              ...widget.features!.map(
                (feature) => Container(
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
                          color: widget.iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          feature.icon,
                          size: 22,
                          color: widget.iconColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Feature text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              feature.description,
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
                ),
              ),

            // Action button - modern design
            if (widget.actionButtonText != null && widget.onAction != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.showLoading ? null : widget.onAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: widget.showLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.actionButtonText!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
