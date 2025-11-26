import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../../image_scan_flow.dart';
import '../bottom_sheet_button.dart';

/// Bottom sheet for selecting image source (gallery, camera, or file)
class ImageCheckBottomSheet extends StatelessWidget {
  const ImageCheckBottomSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ImageCheckBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'home.quickCheck.image.bottomSheet.title'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
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

          // Action buttons
          Row(
            children: [
              Expanded(
                child: BottomSheetButton(
                  icon: Icons.photo_library_outlined,
                  label: 'home.quickCheck.image.bottomSheet.gallery'.tr(),
                  onTap: () {
                    final rootContext = Navigator.of(context, rootNavigator: true).context;
                    Navigator.pop(context);
                    showImageScanFlow(
                      context: rootContext,
                      source: ImageSource.gallery,
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
                    final rootContext = Navigator.of(context, rootNavigator: true).context;
                    Navigator.pop(context);
                    showImageScanFlow(
                      context: rootContext,
                      source: ImageSource.camera,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // File picker button
          SizedBox(
            width: double.infinity,
            child: BottomSheetButton(
              icon: Icons.insert_drive_file_outlined,
              label: 'home.quickCheck.image.bottomSheet.file'.tr(),
              onTap: () {
                final rootContext = Navigator.of(context, rootNavigator: true).context;
                Navigator.pop(context);
                showFileScanFlow(context: rootContext);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
