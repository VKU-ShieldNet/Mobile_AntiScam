import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/bubble_service.dart';
import '../../../../core/widgets/widgets.dart';
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
      
      final wasComplete = _hasOverlayPermission && _hasAccessibilityPermission;
      final nowComplete = overlay && access;
      
      setState(() {
        _hasOverlayPermission = overlay;
        _hasAccessibilityPermission = access;
      });
      
      // Auto-navigate when permissions become complete
      if (nowComplete && !wasComplete) {
        // Small delay to let user see the success state
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
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

  void _navigateToAppSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AppSelectionScreen(),
      ),
    ).then((_) {
      // After selecting apps, go to bubble control screen
      _navigateToBubbleControl();
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
        _hasOverlayPermission && _hasAccessibilityPermission;

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
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Skip button
            if (!allPermissionsGranted)
              Padding(
                padding: const EdgeInsets.all(24),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'button.skip'.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
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
