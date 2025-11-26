// Screen capture removed — methods kept as stubs for compatibility
// Screen capture removed — kept stub for compatibility only

class ScreenCapture {

  /// Xin quyền chụp màn hình (hiện popup hệ thống)
  static Future<bool> requestPermission() async {
    // MediaProjection removed. Return false to indicate not granted.
    return false;
  }

  /// Chụp ảnh màn hình và trả về đường dẫn file PNG
  static Future<String?> capture() async {
    // Not supported — screen capture removed
    return null;
  }
}
