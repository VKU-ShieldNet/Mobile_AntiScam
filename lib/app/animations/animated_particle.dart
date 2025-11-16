import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated floating particle widget for background effects
class AnimatedParticle extends StatefulWidget {
  final int index;
  final int total;
  final Color color;

  const AnimatedParticle({
    Key? key,
    required this.index,
    required this.total,
    required this.color,
  }) : super(key: key);

  @override
  State<AnimatedParticle> createState() => _AnimatedParticleState();
}

class _AnimatedParticleState extends State<AnimatedParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 3000 + widget.index * 500),
      vsync: this,
    )..repeat(reverse: true);

    final double startX = (widget.index / widget.total) * 2 - 1;
    final double startY = (widget.index % 2 == 0) ? -0.5 : 0.5;

    _animation = Tween<Offset>(
      begin: Offset(startX, startY),
      end: Offset(startX + 0.3, startY - 0.3),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: size.width * 0.5 + _animation.value.dx * size.width * 0.3,
          top: size.height * 0.3 + _animation.value.dy * size.height * 0.3,
          child: Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: Container(
              width: 60 + widget.index * 20,
              height: 60 + widget.index * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color,
                    widget.color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
