// lib/app/config/app_config.dart
// Purpose: Central place for app configuration constants and environment flags.
// How to use: Import this file where you need app-level constants, e.g. API base URL, feature flags.

class AppConfig {
  // Example: change at build time or via environment
  static const bool isProduction = false;

  // Example base URL
  static const String apiBaseUrl = 'https://api.example.com';
}
