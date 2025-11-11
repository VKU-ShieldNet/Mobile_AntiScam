import 'package:flutter/material.dart';

/// Simple localization helper for multi-language support
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late final _strings = _getStrings(locale.languageCode);

  Map<String, String> _getStrings(String languageCode) {
    switch (languageCode) {
      case 'vi':
        return _viStrings;
      case 'en':
      default:
        return _enStrings;
    }
  }

  String? get(String key) => _strings[key];

  // English strings
  static const Map<String, String> _enStrings = {
    'appTitle': 'AntiScam',
    'onboarding_title_1': 'Welcome to AntiScam',
    'onboarding_subtitle_1': 'Protect yourself from scams and suspicious calls.',
    'onboarding_title_2': 'Report Easily',
    'onboarding_subtitle_2': 'Quickly report scams and share info with the community.',
    'onboarding_title_3': 'Stay Informed',
    'onboarding_subtitle_3': 'Get tips and alerts to stay one step ahead.',
    'buttonBack': 'Back',
    'buttonNext': 'Next',
    'buttonGetStarted': 'Get Started',
    'buttonSkip': 'Skip',
    'homeTitle': 'Home',
  };

  // Vietnamese strings
  static const Map<String, String> _viStrings = {
    'appTitle': 'AntiScam',
    'onboarding_title_1': 'Chào mừng đến AntiScam',
    'onboarding_subtitle_1': 'Bảo vệ bản thân khỏi các lừa đảo và cuộc gọi đáng ngờ.',
    'onboarding_title_2': 'Báo cáo dễ dàng',
    'onboarding_subtitle_2': 'Báo cáo các vụ lừa đảo và chia sẻ thông tin với cộng đồng.',
    'onboarding_title_3': 'Cập nhật thông tin',
    'onboarding_subtitle_3': 'Nhận mẹo và cảnh báo để luôn tiếp tục.',
    'buttonBack': 'Quay lại',
    'buttonNext': 'Tiếp theo',
    'buttonGetStarted': 'Bắt đầu',
    'buttonSkip': 'Bỏ qua',
    'homeTitle': 'Trang chủ',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

