// lib/navigation.dart

import 'package:flutter/material.dart';
import 'package:voice_based_notification/setup_screen.dart';
import 'home_page.dart';

class Navigation {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => HomePage());

      case '/setup':
        return MaterialPageRoute(builder: (_) => SetupScreen());

      case '/courseRep':
        return MaterialPageRoute(builder: (_) => SetupScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
