import 'package:flutter/material.dart';
import 'app.dart';
import 'modules/nisal/providers/auth_provider.dart';
import 'modules/nisal/providers/route_provider.dart';
import 'modules/nisal/providers/journey_provider.dart';
import 'modules/dumindi/providers/report_provider.dart';
import 'modules/suneth/providers/crowd_provider.dart';
import 'modules/thimaya/providers/map_provider.dart';
import 'modules/thimaya/providers/alert_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  final routeProvider = RouteProvider();
  final journeyProvider = JourneyProvider();
  final reportProvider = ReportProvider();
  final crowdProvider = CrowdProvider();
  final mapProvider = MapProvider();
  final alertProvider = AlertProvider();

  runApp(
    TravelPulseApp(
      authProvider: authProvider,
      routeProvider: routeProvider,
      journeyProvider: journeyProvider,
      reportProvider: reportProvider,
      crowdProvider: crowdProvider,
      mapProvider: mapProvider,
      alertProvider: alertProvider,
    ),
  );
}
