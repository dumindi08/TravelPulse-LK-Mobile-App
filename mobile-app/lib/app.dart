import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'modules/nisal/providers/auth_provider.dart';
import 'modules/nisal/providers/route_provider.dart';
import 'modules/nisal/providers/journey_provider.dart';
import 'modules/dumindi/providers/report_provider.dart';
import 'modules/suneth/providers/crowd_provider.dart';

/// TravelPulse LK — Root Application Widget
class TravelPulseApp extends StatelessWidget {
  final AuthProvider authProvider;
  final RouteProvider? routeProvider;
  final JourneyProvider? journeyProvider;
  final ReportProvider? reportProvider;
  final CrowdProvider? crowdProvider;

  const TravelPulseApp({
    super.key,
    required this.authProvider,
    this.routeProvider,
    this.journeyProvider,
    this.reportProvider,
    this.crowdProvider,
  });

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(
      authProvider: authProvider,
      routeProvider: routeProvider,
      journeyProvider: journeyProvider,
      reportProvider: reportProvider,
      crowdProvider: crowdProvider,
    );

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
