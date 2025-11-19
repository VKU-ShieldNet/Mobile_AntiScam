import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  /// Change app language and save preference
  static Future<void> setLanguage(BuildContext context, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save language preference
    await prefs.setString('language_code', languageCode);
    
    // Update app locale
    await context.setLocale(Locale(languageCode));
  }

  /// Get current saved language code
  static Future<String?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code');
  }

  /// Get current app locale language code
  static String getCurrentLanguage(BuildContext context) {
    return context.locale.languageCode;
  }
}
