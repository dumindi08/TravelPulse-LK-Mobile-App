import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'modules/nisal/providers/auth_provider.dart';

/// TravelPulse LK — Root Application Widget
class TravelPulseApp extends StatelessWidget {
  final AuthProvider authProvider;

  const TravelPulseApp({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(authProvider: authProvider);

    return ListenableBuilder(
      listenable: authProvider,
      builder: (context, _) {
        final String initialRoute = (authProvider.isAuthenticated || authProvider.isGuest)
            ? RouteConstants.mainShell
            : RouteConstants.welcome;

        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: initialRoute,
          onGenerateRoute: appRouter.onGenerateRoute,
        );
      },
    );
  }
}

