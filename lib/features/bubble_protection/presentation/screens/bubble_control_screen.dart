import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/theme/color_schemes.dart';
import '../../../../core/services/bubble_service.dart';
import '../../../app_protection/presentation/screens/app_selection_screen.dart';

class BubbleControlScreen extends StatefulWidget {
  const BubbleControlScreen({Key? key}) : super(key: key);

  @override
  State<BubbleControlScreen> createState() => _BubbleControlScreenState();
}

class _BubbleControlScreenState extends State<BubbleControlScreen> {
  bool _isBubbleActive = false;
  bool _isLoading = false;
  bool _isCheckingPermissions = true;
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityPermission = false;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isCheckingPermissions = true);
    try {
      final overlay = await BubbleService.hasOverlayPermission();
      final access = await BubbleService.hasAccessibilityPermission();
      setState(() {
        _hasOverlayPermission = overlay;
        _hasAccessibilityPermission = access;
        _isCheckingPermissions = false;
      });
    } catch (e) {
      setState(() => _isCheckingPermissions = false);
    }
  }

  Future<void> _requestOverlayPermission() async {
    setState(() => _isRequestingPermission = true);
    try {
      await BubbleService.requestOverlayPermission();
      // re-check after a short delay so the OS can update
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
      // show a small guide and re-check upon 'Done'
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('home.advanced.setup.permission.title'.tr()),
          content: Text('home.advanced.setup.permission.subtitle'.tr()),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'bubble.control.title'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main bubble control card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isBubbleActive
                        ? [
                            AppColors.success.withOpacity(0.1),
                            AppColors.success.withOpacity(0.05),
                          ]
                        : [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isBubbleActive
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isBubbleActive
                            ? AppColors.success
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isBubbleActive
                                    ? AppColors.success
                                    : AppColors.primary)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bubble_chart_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status text
                    Text(
                      _isBubbleActive
                          ? 'bubble.control.status.active'.tr()
                          : 'bubble.control.status.inactive'.tr(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _isBubbleActive
                            ? AppColors.success
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isBubbleActive
                          ? 'bubble.control.description.active'.tr()
                          : 'bubble.control.description.inactive'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Toggle button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading || (!_isBubbleActive && (!_hasOverlayPermission || !_hasAccessibilityPermission)) ? null : _toggleBubble,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBubbleActive
                              ? AppColors.danger
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isBubbleActive
                                    ? 'bubble.control.button.stop'.tr()
                                    : 'bubble.control.button.start'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Small inline setup - only show when permissions are missing
              if (!_isCheckingPermissions && (!_hasOverlayPermission || !_hasAccessibilityPermission)) ...[
                Text(
                  'home.advanced.setup.intro.title'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'home.advanced.setup.permission.subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                          onPressed: (_hasOverlayPermission || _isRequestingPermission) ? null : _requestOverlayPermission,
                          child: Text(_hasOverlayPermission ? 'bubble.control.privacy.note'.tr() : 'home.advanced.setup.permission.grant'.tr()),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                          onPressed: (_hasAccessibilityPermission || _isRequestingPermission) ? null : _requestAccessibilityPermission,
                          child: Text(_hasAccessibilityPermission ? 'bubble.control.privacy.note'.tr() : 'home.advanced.setup.permission.grant'.tr()),
                        ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // If both permissions are granted, show the configure apps button
              if (!_isCheckingPermissions && _hasOverlayPermission && _hasAccessibilityPermission) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AppSelectionScreen()),
                      );
                    },
                    icon: const Icon(Icons.apps_rounded, size: 20),
                    label: Text('home.advanced.selectApps'.tr()),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // How it works section
              Text(
                'bubble.control.howItWorks.title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoCard(
                Icons.touch_app_outlined,
                'bubble.control.howItWorks.tap.title'.tr(),
                'bubble.control.howItWorks.tap.description'.tr(),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                Icons.drag_indicator,
                'bubble.control.howItWorks.move.title'.tr(),
                'bubble.control.howItWorks.move.description'.tr(),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                Icons.security_rounded,
                'bubble.control.howItWorks.scan.title'.tr(),
                'bubble.control.howItWorks.scan.description'.tr(),
              ),

              const SizedBox(height: 32),

              // Privacy note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'bubble.control.privacy.note'.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
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
    );
  }

  Future<void> _toggleBubble() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isBubbleActive) {
        // Stop bubble
        await BubbleService.stopBubble();
        
        if (mounted) {
          setState(() {
            _isBubbleActive = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('bubble.control.toast.stopped'.tr()),
              backgroundColor: AppColors.danger,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // If permissions are missing, ask for them first
        if (!_hasOverlayPermission) {
          await _requestOverlayPermission();
        }
        if (!_hasAccessibilityPermission) {
          await _requestAccessibilityPermission();
        }

        if (!_hasOverlayPermission || !_hasAccessibilityPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('snackbar.permissionsIncomplete'.tr()),
                backgroundColor: AppColors.danger,
              ),
            );
          }
          return;
        }

        // Start bubble
        await BubbleService.startBubble();
        
        if (mounted) {
          setState(() {
            _isBubbleActive = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('bubble.control.toast.started'.tr()),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('bubble.control.toast.error'.tr()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
