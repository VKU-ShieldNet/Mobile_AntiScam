// lib/app/di/injector.dart
// Purpose: Dependency injection setup (e.g., GetIt) and registrations.
// How to use: Call `initializeDependencies()` at app startup to register services.

// Example placeholder; replace with actual DI container like GetIt
class Injector {
  static bool _initialized = false;

  static Future<void> initializeDependencies() async {
    if (_initialized) return;
    // Register services, repositories, datasources here.
    // e.g. getIt.registerSingleton<ApiClient>(ApiClient());

    _initialized = true;
  }
}
