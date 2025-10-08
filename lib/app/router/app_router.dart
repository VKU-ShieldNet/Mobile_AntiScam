// lib/app/router/app_router.dart
// Purpose: Define app routes and route generation logic.
// How to use: Use `AppRouter` to navigate between pages; integrate with Router/GoRouter/AutoRoute as needed.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Example switch on route name
    switch (settings.name) {
      // case '/home':
      //   return MaterialPageRoute(builder: (_) => HomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const _NotFoundPage(),
        );
    }
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
