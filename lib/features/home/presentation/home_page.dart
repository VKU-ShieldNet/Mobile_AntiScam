import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../app/theme/color_schemes.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/services/bubble_service.dart';
import '../../bubble_protection/presentation/screens/bubble_control_screen.dart';
import '../../bubble_protection/presentation/screens/bubble_setup_intro_screen.dart';
import '../../onboarding/presentation/pages/onboarding_screen.dart';
import 'widgets/quick_check_card.dart';
import 'widgets/bottom_sheet_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCheckingPermissions = true;
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final overlay = await BubbleService.hasOverlayPermission();
      final access = await BubbleService.hasAccessibilityPermission();
      if (mounted) {
        setState(() {
          _hasOverlayPermission = overlay;
          _hasAccessibilityPermission = access;
          _isCheckingPermissions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingPermissions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'AntiScam',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          // Settings icon
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
          // Debug button để reset onboarding
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            tooltip: 'Reset Onboarding (Debug)',
            onPressed: () => _resetOnboarding(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Welcome section
              Text(
                'home.greeting'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'home.subtitle'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 32),

              // Quick check section
              Text(
                'home.quickCheck.title'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // Quick check actions - 3 options
              QuickCheckCard(
                icon: Icons.image_outlined,
                title: 'home.quickCheck.image.title'.tr(),
                description: 'home.quickCheck.image.description'.tr(),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                iconColor: AppColors.primary,
                onTap: () {
                  _showImageCheckBottomSheet(context);
                },
              ),
              const SizedBox(height: 12),
              QuickCheckCard(
                icon: Icons.link_outlined,
                title: 'home.quickCheck.link.title'.tr(),
                description: 'home.quickCheck.link.description'.tr(),
                gradient: LinearGradient(
                  colors: [
                    AppColors.info.withOpacity(0.1),
                    AppColors.info.withOpacity(0.05),
                  ],
                ),
                iconColor: AppColors.info,
                onTap: () {
                  _showLinkCheckBottomSheet(context);
                },
              ),
              const SizedBox(height: 12),
              QuickCheckCard(
                icon: Icons.message_outlined,
                title: 'home.quickCheck.message.title'.tr(),
                description: 'home.quickCheck.message.description'.tr(),
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.1),
                    AppColors.success.withOpacity(0.05),
                  ],
                ),
                iconColor: AppColors.success,
                onTap: () {
                  _showMessageCheckBottomSheet(context);
                },
              ),

              const SizedBox(height: 40),

              // (Advanced settings now live in Bubble control)

              // Bubble Control Section
              Text(
                'bubble.section.title'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // Bubble control quick access
              InkWell(
                onTap: () => _navigateToBubbleControl(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.success.withOpacity(0.08),
                        AppColors.success.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bubble_chart_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'bubble.quickAccess.title'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'bubble.quickAccess.description'.tr(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_isCheckingPermissions)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.success,
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: (_hasOverlayPermission && _hasAccessibilityPermission)
                                    ? AppColors.success.withOpacity(0.15)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (_hasOverlayPermission && _hasAccessibilityPermission)
                                    ? 'home.advanced.status.ready'.tr()
                                    : 'home.advanced.status.setup'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: (_hasOverlayPermission && _hasAccessibilityPermission) ? AppColors.success : Colors.grey[700],
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          const Icon(
                            Icons.arrow_forward,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetOnboarding(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('home.resetDialog.title'.tr()),
        content: Text(
          'home.resetDialog.content'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('home.resetDialog.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('home.resetDialog.reset'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await OnboardingService.resetOnboarding();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  void _showImageCheckBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'home.quickCheck.image.bottomSheet.title'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'home.quickCheck.image.bottomSheet.subtitle'.tr(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: BottomSheetButton(
                    icon: Icons.photo_library_outlined,
                    label: 'home.quickCheck.image.bottomSheet.gallery'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement gallery pick
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('home.developing'.tr())),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BottomSheetButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'home.quickCheck.image.bottomSheet.camera'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement camera
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('home.developing'.tr())),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLinkCheckBottomSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'home.quickCheck.link.bottomSheet.title'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'home.quickCheck.link.bottomSheet.placeholder'.tr(),
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement link check
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('home.developing'.tr())),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kiểm tra',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMessageCheckBottomSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'home.quickCheck.message.bottomSheet.title'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'home.quickCheck.message.bottomSheet.placeholder'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement message check
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('home.developing'.tr())),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kiểm tra',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToBubbleControl(BuildContext context) async {
    // Check if permissions are already granted
    final hasOverlay = await BubbleService.hasOverlayPermission();
    final hasAccessibility = await BubbleService.hasAccessibilityPermission();
    
    if (!context.mounted) return;
    
    if (hasOverlay && hasAccessibility) {
      // Permissions granted, go directly to bubble control
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BubbleControlScreen(),
        ),
      );
    } else {
      // Need setup, show intro flow first
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BubbleSetupIntroScreen(),
        ),
      );
    }
  }
}
