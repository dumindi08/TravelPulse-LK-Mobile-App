import 'package:flutter_test/flutter_test.dart';
import 'package:travelpulse_mobile/app.dart';
import 'package:travelpulse_mobile/modules/nisal/providers/auth_provider.dart';
import 'package:travelpulse_mobile/modules/nisal/providers/route_provider.dart';
import 'package:travelpulse_mobile/modules/nisal/providers/journey_provider.dart';
import 'package:travelpulse_mobile/modules/dumindi/providers/report_provider.dart';
import 'package:travelpulse_mobile/modules/dumindi/models/report_category_model.dart';
import 'package:travelpulse_mobile/modules/dumindi/models/community_report_model.dart';
import 'package:travelpulse_mobile/modules/dumindi/services/report_service.dart';
import 'package:travelpulse_mobile/modules/nisal/models/schedule_model.dart';
import 'package:travelpulse_mobile/modules/nisal/services/route_service.dart';

void main() {
  group('TravelPulse LK — Full Mobile Test Suite (Stages 2, 3 & 4)', () {
    testWidgets('1. Onboarding & Welcome screen smoke test', (WidgetTester tester) async {
      final authProvider = AuthProvider();
      final routeProvider = RouteProvider();
      final journeyProvider = JourneyProvider();
      final reportProvider = ReportProvider();

      await tester.pumpWidget(
        TravelPulseApp(
          authProvider: authProvider,
          routeProvider: routeProvider,
          journeyProvider: journeyProvider,
          reportProvider: reportProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TravelPulse LK'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('2. Guest commuter access to Home & Navigation Shell', (WidgetTester tester) async {
      final authProvider = AuthProvider();
      final routeProvider = RouteProvider();
      final journeyProvider = JourneyProvider();
      final reportProvider = ReportProvider();

      authProvider.continueAsGuest();

      await tester.pumpWidget(
        TravelPulseApp(
          authProvider: authProvider,
          routeProvider: routeProvider,
          journeyProvider: journeyProvider,
          reportProvider: reportProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Routes'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Live Network'), findsOneWidget);
    });

    test('3. RouteService & RouteProvider search and filtering (Nisal)', () async {
      final service = RouteService();
      final allRoutes = await service.getRoutes();
      expect(allRoutes.success, isTrue);
      expect(allRoutes.data!.length, greaterThanOrEqualTo(4));

      final busRoutes = await service.getRoutes(transportType: 'bus');
      expect(busRoutes.success, isTrue);
      expect(busRoutes.data!.every((r) => r.isBus), isTrue);

      final searchResult = await service.searchRoutesByOriginDestination(
        origin: 'Colombo Fort',
        destination: 'Maharagama',
      );
      expect(searchResult.success, isTrue);
      expect(searchResult.data!.any((r) => r.routeNumber == '138'), isTrue);
    });

    test('4. RouteScheduleModel serialization and timetables (Nisal)', () async {
      final service = RouteService();
      final schedules = await service.getRouteSchedules(1, direction: 'outbound');
      expect(schedules.success, isTrue);
      expect(schedules.data!.isNotEmpty, isTrue);

      final first = schedules.data!.first;
      expect(first.isOutbound, isTrue);

      final json = first.toJson();
      final reconstructed = RouteScheduleModel.fromJson(json);
      expect(reconstructed.id, equals(first.id));
      expect(reconstructed.departureTime, equals(first.departureTime));
    });

    test('5. JourneyProvider starting, tracking and completing journey (Nisal)', () async {
      final routeProvider = RouteProvider();
      final journeyProvider = JourneyProvider();

      await routeProvider.loadRoutes();
      final route138 = routeProvider.routes.firstWhere((r) => r.routeNumber == '138');

      final started = await journeyProvider.startJourney(
        userId: 1,
        route: route138,
        originStop: route138.stops.first,
        destinationStop: route138.stops.last,
      );

      expect(started, isTrue);
      expect(journeyProvider.hasActiveJourney, isTrue);
      expect(journeyProvider.activeJourney!.routeNumber, equals('138'));

      final completed = await journeyProvider.completeJourney(journeyProvider.activeJourney!.id);
      expect(completed, isTrue);
      expect(journeyProvider.hasActiveJourney, isFalse);
    });

    test('6. ReportCategoryModel taxonomy contains exactly 6 categories (Dumindi)', () {
      final categories = ReportCategoryModel.allCategories;
      expect(categories.length, equals(6));

      final codes = categories.map((c) => c.code).toList();
      expect(codes, containsAll([
        'CROWD',
        'ROAD_CONDITION',
        'TRANSPORT_TRACKING',
        'SERVICE_DISRUPTION',
        'ACCIDENT_INCIDENT',
        'OTHER',
      ]));
    });

    test('7. ReportProvider submitting report with anonymous flag retaining ownership (Dumindi)', () async {
      final reportProvider = ReportProvider();

      final created = await reportProvider.submitReport(
        userId: 1,
        userName: 'Kamal Perera',
        isAnonymous: true,
        categoryId: 4,
        categoryName: 'Service Disruption',
        routeId: 1,
        routeNumber: '138',
        latitude: 6.9147,
        longitude: 79.8653,
        locationDescription: 'Town Hall roundabout',
        title: 'Broken Bus Center Lane',
        description: 'Engine failure causing severe traffic backup towards Maradana.',
        disruptionReason: 'Vehicle Breakdown',
      );

      expect(created, isNotNull);
      expect(created!.isAnonymous, isTrue);
      expect(created.userId, equals(1)); // Retains internal ownership!
      expect(created.displayReporter, equals('Anonymous Commuter')); // Masks public name!
      expect(created.disruptionReason, equals('Vehicle Breakdown'));
      expect(created.isOwnedBy(1), isTrue);
      expect(created.isOwnedBy(2), isFalse);
    });

    test('8. ReportService deleting owned report vs forbidden deletion (Dumindi)', () async {
      final service = ReportService();

      // Submit test report authored by Kamal (userId: 1)
      final res = await service.submitReport(
        userId: 1,
        userName: 'Kamal Perera',
        isAnonymous: false,
        categoryId: 2,
        categoryName: 'Road Condition',
        latitude: 6.8920,
        longitude: 79.8580,
        locationDescription: 'Bauddhaloka Mawatha',
        title: 'Flash flood at junction',
        description: 'Road inundated with 1 foot of water.',
      );
      expect(res.success, isTrue);
      final reportId = res.data!.id;

      // Dilshan (userId: 2) attempts to delete Kamal's report -> Must fail!
      final forbiddenDelete = await service.deleteReport(reportId: reportId, userId: 2);
      expect(forbiddenDelete.success, isFalse);
      expect(forbiddenDelete.code, equals('FORBIDDEN_DELETE'));

      // Kamal (userId: 1) deletes own report -> Must succeed!
      final authorizedDelete = await service.deleteReport(reportId: reportId, userId: 1);
      expect(authorizedDelete.success, isTrue);

      // Verify report is deleted
      final check = await service.getReportById(reportId);
      expect(check.success, isFalse);
    });

    test('9. CommunityReportModel JSON serialization and null safety (Dumindi)', () {
      final model = CommunityReportModel(
        id: 301,
        userId: 1,
        userName: 'Kamal Perera',
        isAnonymous: true,
        categoryId: 4,
        categoryName: 'Service Disruption',
        disruptionReason: 'Signal Failure',
        latitude: 7.0270,
        longitude: 79.9230,
        locationDescription: 'Ragama Station',
        title: 'Main line train signal down',
        description: 'Delays of 20 minutes across commuter trains.',
        createdAt: DateTime.now(),
      );

      final json = model.toJson();
      expect(json['isAnonymous'], isTrue);
      expect(json['disruptionReason'], equals('Signal Failure'));

      final reconstructed = CommunityReportModel.fromJson(json);
      expect(reconstructed.id, equals(301));
      expect(reconstructed.displayReporter, equals('Anonymous Commuter'));
      expect(reconstructed.disruptionReason, equals('Signal Failure'));
    });
  });
}
