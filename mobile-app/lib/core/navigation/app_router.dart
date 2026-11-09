import 'package:flutter/material.dart';
import '../constants/route_constants.dart';
import '../../modules/nisal/providers/auth_provider.dart';
import '../../modules/nisal/providers/route_provider.dart';
import '../../modules/nisal/providers/journey_provider.dart';
import '../../modules/dumindi/providers/report_provider.dart';
import '../../modules/dumindi/models/community_report_model.dart';
import '../../modules/dumindi/views/create_report_view.dart';
import '../../modules/dumindi/views/report_submitted_view.dart';
import '../../modules/dumindi/views/recent_reports_view.dart';
import '../../modules/dumindi/views/report_details_view.dart';
import '../../modules/dumindi/views/my_reports_view.dart';
import '../../modules/nisal/views/welcome_view.dart';
import '../../modules/nisal/views/sign_in_view.dart';
import '../../modules/nisal/views/sign_up_view.dart';
import '../../modules/nisal/views/route_search_view.dart';
import '../../modules/nisal/views/route_results_view.dart';
import '../../modules/nisal/views/route_details_view.dart';
import 'bottom_nav_scaffold.dart';

/// TravelPulse LK — Global Application Router
/// Generates type-safe routes across all application modules.
class AppRouter {
  final AuthProvider authProvider;
  final RouteProvider routeProvider;
  final JourneyProvider journeyProvider;
  final ReportProvider reportProvider;

  AppRouter({
    required this.authProvider,
    RouteProvider? routeProvider,
    JourneyProvider? journeyProvider,
    ReportProvider? reportProvider,
  })  : routeProvider = routeProvider ?? RouteProvider(),
        journeyProvider = journeyProvider ?? JourneyProvider(),
        reportProvider = reportProvider ?? ReportProvider();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 1. Onboarding & Authentication (Nisal)
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

      // 2. Navigation Shell (5 Bottom Tabs)
      case RouteConstants.mainShell:
        final int initialIndex = (settings.arguments is int) ? settings.arguments as int : 0;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BottomNavScaffold(
            authProvider: authProvider,
            routeProvider: routeProvider,
            journeyProvider: journeyProvider,
            reportProvider: reportProvider,
            initialIndex: initialIndex,
          ),
        );

      // 3. Journey & Route Management (Nisal)
      case RouteConstants.searchRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteSearchView(
            routeProvider: routeProvider,
            journeyProvider: journeyProvider,
            authProvider: authProvider,
          ),
        );

      case RouteConstants.routeResults:
        final args = settings.arguments as Map<String, String>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteResultsView(
            origin: args?['origin'] ?? '',
            destination: args?['destination'] ?? '',
            routeProvider: routeProvider,
            journeyProvider: journeyProvider,
            authProvider: authProvider,
          ),
        );

      case RouteConstants.routeDetails:
        final routeId = (settings.arguments is int) ? settings.arguments as int : 1;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RouteDetailsView(
            routeId: routeId,
            routeProvider: routeProvider,
            journeyProvider: journeyProvider,
            authProvider: authProvider,
          ),
        );

      // 4. Community Reporting & Disruption Management (Dumindi)
      case RouteConstants.createReport:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreateReportView(
            authProvider: authProvider,
            reportProvider: reportProvider,
            routeProvider: routeProvider,
          ),
        );

      case RouteConstants.reportSubmitted:
        final report = settings.arguments as CommunityReportModel?;
        if (report == null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => RecentReportsView(
              authProvider: authProvider,
              reportProvider: reportProvider,
              routeProvider: routeProvider,
            ),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ReportSubmittedView(
            report: report,
            authProvider: authProvider,
            reportProvider: reportProvider,
          ),
        );

      case RouteConstants.recentReports:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RecentReportsView(
            authProvider: authProvider,
            reportProvider: reportProvider,
            routeProvider: routeProvider,
          ),
        );

      case RouteConstants.reportDetails:
        final reportId = (settings.arguments is int) ? settings.arguments as int : 101;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ReportDetailsView(
            reportId: reportId,
            authProvider: authProvider,
            reportProvider: reportProvider,
          ),
        );

      case RouteConstants.myReports:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MyReportsView(
            authProvider: authProvider,
            reportProvider: reportProvider,
            routeProvider: routeProvider,
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
