import 'package:flutter/material.dart';
import '../constants/route_constants.dart';
import '../../modules/nisal/providers/auth_provider.dart';
import '../../modules/nisal/views/welcome_view.dart';
import '../../modules/nisal/views/sign_in_view.dart';
import '../../modules/nisal/views/sign_up_view.dart';
import 'bottom_nav_scaffold.dart';

/// TravelPulse LK — Global Application Router
/// Generates type-safe routes across all application modules.
class AppRouter {
  final AuthProvider authProvider;

  const AppRouter({required this.authProvider});

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.welcome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => WelcomeView(authProvider: authProvider),
        );

      case RouteConstants.signIn:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SignInView(authProvider: authProvider),
        );

      case RouteConstants.signUp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SignUpView(authProvider: authProvider),
        );

      case RouteConstants.mainShell:
        final int initialIndex = (settings.arguments is int) ? settings.arguments as int : 0;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BottomNavScaffold(
            authProvider: authProvider,
            initialIndex: initialIndex,
          ),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Route Not Found')),
            body: Center(
              child: Text('No route defined for "${settings.name}".'),
            ),
          ),
        );
    }
  }
}

