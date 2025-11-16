import 'package:flutter/material.dart';

/// Creates fade and scale animations for widget transitions
class FadeScaleAnimationController {
  late AnimationController fadeController;
  late AnimationController scaleController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  FadeScaleAnimationController({
    required TickerProvider vsync,
    Duration fadeDuration = const Duration(milliseconds: 600),
    Duration scaleDuration = const Duration(milliseconds: 800),
  }) {
    fadeController = AnimationController(
      duration: fadeDuration,
      vsync: vsync,
    );

    scaleController = AnimationController(
      duration: scaleDuration,
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.easeInOut),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.elasticOut),
    );
  }

  void start() {
    fadeController.forward();
    scaleController.forward();
  }

  void reset() {
    fadeController.reset();
    scaleController.reset();
  }

  void dispose() {
    fadeController.dispose();
    scaleController.dispose();
  }
}
