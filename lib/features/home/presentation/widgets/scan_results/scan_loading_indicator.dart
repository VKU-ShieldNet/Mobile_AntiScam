import 'package:flutter/material.dart';
import 'dart:async';

class ScanLoadingIndicator extends StatefulWidget {
  const ScanLoadingIndicator({Key? key}) : super(key: key);

  @override
  State<ScanLoadingIndicator> createState() => _ScanLoadingIndicatorState();
}

class _ScanLoadingIndicatorState extends State<ScanLoadingIndicator>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  final List<String> _steps = [
    'Đang quét...',
    'Đang chuẩn bị...',
    'Đang phân tích sâu...',
    'Đang kiểm tra mối nguy...',
    'Sắp hoàn thành...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _startStepRotation();
  }

  void _startStepRotation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _currentStep = (_currentStep + 1) % _steps.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated scanning icon with pulse effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF724CDA).withOpacity(0.2),
                        const Color(0xFF724CDA).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF724CDA)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // Animated step text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _steps[_currentStep],
              key: ValueKey<int>(_currentStep),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF37352F),
                height: 1.3,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Vui lòng đợi trong giây lát',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
