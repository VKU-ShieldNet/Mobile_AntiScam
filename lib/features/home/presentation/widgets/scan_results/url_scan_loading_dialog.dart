import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class UrlScanLoadingDialog extends StatefulWidget {
  const UrlScanLoadingDialog({Key? key}) : super(key: key);

  @override
  State<UrlScanLoadingDialog> createState() => _UrlScanLoadingDialogState();
}

class _UrlScanLoadingDialogState extends State<UrlScanLoadingDialog> {
  late String _currentMessage;
  Timer? _timer;

  final List<String> _scanningMessages = [
    'Đang phân tích URL...',
    'Đang kiểm tra độ an toàn...',
    'Đang quét sâu website...',
    'Đang đánh giá mức độ nguy hiểm...',
    'Đang tổng hợp kết quả...',
    'Đang xác thực nguồn gốc...',
    'Đang kiểm tra lịch sử...',
    'Đang phân tích nội dung...',
  ];

  @override
  void initState() {
    super.initState();
    _currentMessage = _getRandomMessage();
    _startAnimation();
  }

  String _getRandomMessage() {
    return _scanningMessages[Random().nextInt(_scanningMessages.length)];
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (mounted) {
        setState(() {
          _currentMessage = _getRandomMessage();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Single spinning indicator
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Đang quét...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF37352F),
              ),
            ),

            const SizedBox(height: 16),

            // Animated status text with random messages
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
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
                _currentMessage,
                key: ValueKey<String>(_currentMessage),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
