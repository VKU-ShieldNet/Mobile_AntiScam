import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'features/home/presentation/home_page.dart';
import 'app/theme/color_schemes.dart';
import 'app/presentation/pages/splash_screen.dart';
import 'core/providers/screenshot_monitor_provider.dart';
import 'core/services/app_monitor_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize SharedPreferences for app data storage
  await SharedPreferences.getInstance();

  // Set default protected apps
  final appMonitor = AppMonitorService();
  final protectedApps = AppMonitorService.getDefaultProtectedApps();
  await appMonitor.setProtectedApps(protectedApps);
  debugPrint('✅ Protected apps configured: ${protectedApps.length} apps');

  // Start screenshot monitoring globally
  ScreenshotMonitorProvider().startMonitoring();
  debugPrint('✅ Screenshot monitoring started');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntiScam',
        theme: ThemeData(
          primaryColor: AppColors.primary80,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary80,
            primary: AppColors.primary80,
            secondary: AppColors.secondary,
          ),
          scaffoldBackgroundColor: AppColors.default0,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.primary80),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary80,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary80,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: AppColors.primary20, width: 2),
            ),
          ),
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // Check onboarding status to display appropriate screen
        home: const SplashScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomePage(),
        },
      );
  }
}
