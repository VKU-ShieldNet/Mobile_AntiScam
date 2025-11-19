import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/bubble_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../app/theme/color_schemes.dart';
import '../../../app_protection/presentation/screens/app_selection_screen.dart';
import 'bubble_control_screen.dart';

class BubbleSetupPermissionScreen extends StatefulWidget {
  const BubbleSetupPermissionScreen({Key? key}) : super(key: key);

  @override
  State<BubbleSetupPermissionScreen> createState() =>
      _BubbleSetupPermissionScreenState();
}

class _BubbleSetupPermissionScreenState
    extends State<BubbleSetupPermissionScreen> with WidgetsBindingObserver {
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityPermission = false;
  bool _hasScreenCapturePermission = false;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app resumes (user comes back from settings), re-check permissions
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final overlay = await BubbleService.hasOverlayPermission();
      final access = await BubbleService.hasAccessibilityPermission();
      
      final wasComplete = _hasOverlayPermission && _hasAccessibilityPermission && _hasScreenCapturePermission;
      final nowComplete = overlay && access && _hasScreenCapturePermission;
      
      setState(() {
        _hasOverlayPermission = overlay;
        _hasAccessibilityPermission = access;
      });
      
      // Auto-navigate when all permissions become complete
      if (nowComplete && !wasComplete) {
        // Small delay to let user see the success state
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // All 3 permissions complete -> go to app selection
          _navigateToAppSelection();
        }
      }
    } catch (e) {
      // Error checking permissions
    }
  }

  Future<void> _requestOverlayPermission() async {
    setState(() => _isRequestingPermission = true);
    try {
      await BubbleService.requestOverlayPermission();
      await Future.delayed(const Duration(milliseconds: 600));
      final overlay = await BubbleService.hasOverlayPermission();
      setState(() {
        _hasOverlayPermission = overlay;
        _isRequestingPermission = false;
      });
    } catch (e) {
      setState(() => _isRequestingPermission = false);
    }
  }

  Future<void> _requestAccessibilityPermission() async {
    setState(() => _isRequestingPermission = true);
    try {
      await BubbleService.requestAccessibilityPermission();
      if (!mounted) return;
      
      // Show a dialog to guide user
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('bubble.setup.permission.accessibility.dialog.title'.tr()),
          content: Text('bubble.setup.permission.accessibility.dialog.message'.tr()),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final access = await BubbleService.hasAccessibilityPermission();
                setState(() {
                  _hasAccessibilityPermission = access;
                  _isRequestingPermission = false;
                });
              },
              child: Text('button.continue'.tr()),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isRequestingPermission = false);
    }
  }

  Future<void> _requestScreenCapturePermission() async {
    // Show explanation modal first
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'bubble.setup.permission.screenCapture.modal.title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'bubble.setup.permission.screenCapture.modal.description'.tr(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'bubble.setup.permission.screenCapture.modal.warning'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'bubble.setup.permission.screenCapture.modal.instruction'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'button.cancel'.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('button.continue'.tr()),
          ),
        ],
      ),
    );

    if (shouldContinue != true) {
      return;
    }

    setState(() => _isRequestingPermission = true);
    try {
      final granted = await PermissionService.requestScreenCapturePermission();
      setState(() {
        _hasScreenCapturePermission = granted;
        _isRequestingPermission = false;
      });
      
      // Check if all permissions are now complete and auto-navigate
      if (granted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && _hasOverlayPermission && _hasAccessibilityPermission && _hasScreenCapturePermission) {
          _navigateToAppSelection();
        }
      }
    } catch (e) {
      setState(() => _isRequestingPermission = false);
    }
  }

  void _navigateToAppSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AppSelectionScreen(),
      ),
    ).then((result) {
      // After user confirms app selection, go to BubbleControl
      if (result == true) {
        _navigateToBubbleControl();
      }
    });
  }

  void _navigateToBubbleControl() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const BubbleControlScreen(),
      ),
      (route) => route.isFirst, // Keep only the first route (home)
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPermissionsGranted =
        _hasOverlayPermission && _hasAccessibilityPermission && _hasScreenCapturePermission;

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
                      icon: Icons.verified_user_outlined,
                      title: 'bubble.setup.permission.title'.tr(),
                      subtitle: 'bubble.setup.permission.subtitle'.tr(),
                    ),
                    const SizedBox(height: 32),

                    // Step 1: Overlay Permission
                    PermissionStepCard(
                      stepNumber: 1,
                      title: 'bubble.setup.permission.overlay.title'.tr(),
                      description: 'bubble.setup.permission.overlay.description'.tr(),
                      isGranted: _hasOverlayPermission,
                      onRequest: _requestOverlayPermission,
                      buttonText: 'bubble.setup.permission.grantButton'.tr(),
                      isLoading: _isRequestingPermission,
                    ),
                    const SizedBox(height: 12),

                    // Step 2: Accessibility Permission
                    PermissionStepCard(
                      stepNumber: 2,
                      title: 'bubble.setup.permission.accessibility.title'.tr(),
                      description: 'bubble.setup.permission.accessibility.description'.tr(),
                      isGranted: _hasAccessibilityPermission,
                      onRequest: _requestAccessibilityPermission,
                      buttonText: 'bubble.setup.permission.grantButton'.tr(),
                      enabled: _hasOverlayPermission,
                      isLoading: _isRequestingPermission,
                    ),
                    const SizedBox(height: 12),

                    // Step 3: Screen Capture Permission
                    PermissionStepCard(
                      stepNumber: 3,
                      title: 'bubble.setup.permission.screenCapture.title'.tr(),
                      description: 'bubble.setup.permission.screenCapture.description'.tr(),
                      isGranted: _hasScreenCapturePermission,
                      onRequest: _requestScreenCapturePermission,
                      buttonText: 'bubble.setup.permission.grantButton'.tr(),
                      enabled: _hasOverlayPermission && _hasAccessibilityPermission,
                      isLoading: _isRequestingPermission,
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Done button (only show when all permissions granted)
            if (allPermissionsGranted)
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToAppSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'button.done'.tr(),
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
