import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import '../../../app/theme/color_schemes.dart';
import '../../../core/services/bubble_service.dart';
import '../../../core/services/onboarding_service.dart';
import '../../bubble_protection/presentation/screens/bubble_control_screen.dart';
import '../../onboarding/presentation/pages/onboarding_screen.dart';
import '../../bubble_protection/presentation/screens/bubble_setup_intro_screen.dart';
import 'widgets/quick_check_card.dart';
import 'widgets/bottom_sheet_button.dart';
import 'widgets/section_header.dart';
import 'widgets/bubble_control_card.dart';

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

  /// Reset onboarding and navigate to the onboarding flow
  Future<void> _resetOnboarding(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('home.resetDialog.title'.tr()),
        content: Text('home.resetDialog.content'.tr()),
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
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
          // Small debug action to reset onboarding for testing (only visible in debug builds)
          if (kDebugMode)
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
              SectionHeader(title: 'home.quickCheck.title'.tr()),
              const SizedBox(height: 16),

              // Quick check actions - 3 options
              QuickCheckCard(
                icon: Icons.image_outlined,
                title: 'home.quickCheck.image.title'.tr(),
                description: 'home.quickCheck.image.description'.tr(),
                iconColor: AppColors.primary70,
                onTap: () {
                  _showImageCheckBottomSheet(context);
                },
              ),
              const SizedBox(height: 12),
              QuickCheckCard(
                icon: Icons.link_outlined,
                title: 'home.quickCheck.link.title'.tr(),
                description: 'home.quickCheck.link.description'.tr(),
                iconColor: AppColors.primary70,
                onTap: () {
                  _showLinkCheckBottomSheet(context);
                },
              ),
              const SizedBox(height: 12),
              QuickCheckCard(
                icon: Icons.message_outlined,
                title: 'home.quickCheck.message.title'.tr(),
                description: 'home.quickCheck.message.description'.tr(),
                iconColor: AppColors.primary70,
                onTap: () {
                  _showMessageCheckBottomSheet(context);
                },
              ),

              const SizedBox(height: 40),

              // Bubble Control Section
              SectionHeader(title: 'bubble.section.title'.tr()),
              const SizedBox(height: 16),

              BubbleControlCard(
                hasOverlayPermission: _hasOverlayPermission,
                hasAccessibilityPermission: _hasAccessibilityPermission,
                isLoading: _isCheckingPermissions,
                onTap: () => _navigateToBubbleControl(context),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
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
                child: Text(
                  'home.quickCheck.checkButton'.tr(),
                  style: const TextStyle(
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
                child: Text(
                  'home.quickCheck.message.bottomSheet.checkButton'.tr(),
                  style: const TextStyle(
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
