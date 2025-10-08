// lib/core/utils/extensions.dart
// Purpose: Common extension methods used across the app.
// How to use: Import this file to bring extensions into scope.

// Extension on nullable String to safely check for null or empty
extension NullableStringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

// Add other small helpers here
