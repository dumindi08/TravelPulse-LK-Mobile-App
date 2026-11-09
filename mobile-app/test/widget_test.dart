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
import 'package:travelpulse_mobile/modules/suneth/models/crowd_estimate_model.dart';
import 'package:travelpulse_mobile/modules/suneth/models/user_reputation_model.dart';
import 'package:travelpulse_mobile/modules/suneth/services/crowd_service.dart';
import 'package:travelpulse_mobile/modules/suneth/providers/crowd_provider.dart';
import 'package:travelpulse_mobile/modules/thimaya/models/road_incident_model.dart';
import 'package:travelpulse_mobile/modules/thimaya/models/travel_alert_model.dart';
import 'package:travelpulse_mobile/modules/thimaya/models/alert_subscription_model.dart';
import 'package:travelpulse_mobile/modules/thimaya/services/location_service.dart';
import 'package:travelpulse_mobile/modules/thimaya/services/alert_service.dart';
import 'package:travelpulse_mobile/modules/thimaya/providers/alert_provider.dart';
import 'package:travelpulse_mobile/modules/thimaya/providers/map_provider.dart';

void main() {
  group('TravelPulse LK — Full Mobile Test Suite (Stages 2, 3, 4, 5 & 6)', () {
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

    test('10. CrowdAggregationModel and CrowdEstimateModel serialization & dual-target logic (Suneth)', () {
      // 10a. Route aggregation
      final routeAgg = CrowdAggregationModel(
        targetType: 'route',
        targetId: 1,
        targetName: 'Route 138 (Pettah - Homagama)',
        currentCrowdLevel: 'very_crowded',
        sampleCount: 8,
        confidenceScore: 88.5,
        averageWaitTimeMinutes: 18,
        timeSlot: DateTime.now(),
      );
      expect(routeAgg.isRoute, isTrue);
      expect(routeAgg.isStop, isFalse);

      final routeJson = routeAgg.toJson();
      final routeParsed = CrowdAggregationModel.fromJson(routeJson);
      expect(routeParsed.targetId, equals(1));
      expect(routeParsed.currentCrowdLevel, equals('very_crowded'));
      expect(routeParsed.confidenceScore, equals(88.5));

      // 10b. Stop aggregation
      final stopAgg = CrowdAggregationModel(
        targetType: 'stop',
        targetId: 101,
        targetName: 'Pettah Main Bus Stand',
        currentCrowdLevel: 'crowded',
        sampleCount: 9,
        confidenceScore: 91.0,
        averageWaitTimeMinutes: 20,
        timeSlot: DateTime.now(),
      );
      expect(stopAgg.isStop, isTrue);
      expect(stopAgg.isRoute, isFalse);
    });

    test('11. UserReputationModel trust tier calculations and accuracy rates (Suneth)', () {
      final highRep = UserReputationModel(
        userId: 1,
        reputationScore: 88.0,
        totalReportsSubmitted: 10,
        verifiedReportsCount: 9,
        rejectedReportsCount: 0,
        totalVotesCast: 25,
        updatedAt: DateTime.now(),
      );
      expect(highRep.trustTier, equals('Trusted Commuter'));
      expect(highRep.accuracyRate, equals(90.0));

      final pioneerRep = UserReputationModel(
        userId: 5,
        reputationScore: 98.0,
        totalReportsSubmitted: 20,
        verifiedReportsCount: 20,
        rejectedReportsCount: 0,
        totalVotesCast: 50,
        updatedAt: DateTime.now(),
      );
      expect(pioneerRep.trustTier, equals('Elite Contributor'));
      expect(pioneerRep.accuracyRate, equals(100.0));

      final newRep = UserReputationModel.initial(99);
      expect(newRep.trustTier, equals('New Commuter'));
      expect(newRep.reputationScore, equals(10.0));
    });

    test('12. CrowdService & CrowdProvider aggregation loading and estimate submission (Suneth)', () async {
      final service = CrowdService();
      final provider = CrowdProvider(service: service);

      await provider.loadAggregations();
      expect(provider.aggregations.isNotEmpty, isTrue);
      expect(provider.routeAggregations.isNotEmpty, isTrue);
      expect(provider.stopAggregations.isNotEmpty, isTrue);

      final level138 = provider.getCrowdLevelForRoute(1);
      expect(level138, isNotEmpty);

      // Submit observation for Route 100
      final submitted = await provider.submitCrowdEstimate(
        routeId: 2,
        crowdLevel: 'crowded',
        passengerWaitTimeMinutes: 12,
        userId: 1,
      );
      expect(submitted, isTrue);
      expect(provider.getCrowdLevelForRoute(2), equals('crowded'));
    });

    test('13. CrowdProvider peer voting updates report reliability score (Suneth)', () async {
      final provider = CrowdProvider();

      final voteResult = await provider.voteOnReport(
        reportId: 101,
        userId: 2,
        voteType: 'upvote',
      );

      expect(voteResult, isNotNull);
      expect(voteResult!['reportId'], equals(101));
      expect(voteResult['userVote'], equals('upvote'));
      expect(voteResult['reliabilityScore'], greaterThanOrEqualTo(80.0));
      expect(voteResult['confidenceStatus'], equals('verified'));
    });

    test('14. RoadIncidentModel and TravelAlertModel serialization and helper properties (Thimaya)', () {
      final incident = RoadIncidentModel(
        id: 401,
        sourceReportId: 101,
        incidentType: 'flooding',
        latitude: 6.8920,
        longitude: 79.8580,
        addressText: 'Bauddhaloka Mawatha near Thunmulla',
        severity: 'critical',
        radiusMeters: 250,
        isActive: true,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(incident.isCritical, isTrue);
      expect(incident.displayName, equals('Flash Flood / Waterlogging'));
      final json = incident.toJson();
      final reconstructed = RoadIncidentModel.fromJson(json);
      expect(reconstructed.id, equals(401));
      expect(reconstructed.incidentType, equals('flooding'));
      expect(reconstructed.addressText, contains('Bauddhaloka'));

      final alert = TravelAlertModel(
        id: 501,
        title: 'Flash Flood Warning — Thunmulla Junction',
        message: 'Severe waterlogging at Bauddhaloka Mawatha.',
        alertType: 'road_condition',
        severity: 'critical',
        targetRouteId: 1,
        targetRouteNumber: '138',
        targetLatitude: 6.8920,
        targetLongitude: 79.8580,
        targetRadiusKm: 2.5,
        status: 'active',
        createdAt: DateTime.now(),
      );

      expect(alert.isActive, isTrue);
      expect(alert.isCritical, isTrue);
      final alertJson = alert.toJson();
      final alertReconstructed = TravelAlertModel.fromJson(alertJson);
      expect(alertReconstructed.id, equals(501));
      expect(alertReconstructed.targetRouteNumber, equals('138'));
    });

    test('15. LocationService GPS permissions, manual selection & distance calculation (Thimaya)', () async {
      final locationService = LocationService();

      // Default state
      expect(locationService.hasLocationPermission, isTrue);
      expect(locationService.currentLocation.label, contains('Colombo Fort'));
      expect(locationService.currentLocation.isManual, isFalse);

      // Distance calculation: Colombo Fort to Bambalapitiya (~5.2 km)
      final distance = LocationService.distanceBetweenKm(
        6.9355, 79.8530, // Fort
        6.8890, 79.8560, // Bambalapitiya
      );
      expect(distance, greaterThan(4.5));
      expect(distance, lessThan(6.0));

      // Simulate GPS permission denied
      locationService.simulatePermissionDenied(permanently: true);
      expect(locationService.hasLocationPermission, isFalse);
      expect(locationService.permissionState, equals(LocationPermissionState.permanentlyDenied));

      // Commuter selects manual location
      locationService.setManualLocation(
        latitude: 6.8480,
        longitude: 79.9265,
        label: 'Maharagama Bus Stand',
      );
      expect(locationService.currentLocation.isManual, isTrue);
      expect(locationService.currentLocation.label, equals('Maharagama Bus Stand'));
      expect(locationService.currentLocation.latitude, equals(6.8480));
    });

    test('16. AlertService & AlertProvider loading alerts and commuter preferences (Thimaya)', () async {
      final alertService = AlertService();
      final alertProvider = AlertProvider(service: alertService);

      await alertProvider.loadAlerts();
      expect(alertProvider.alerts.isNotEmpty, isTrue);
      expect(alertProvider.criticalAlerts.isNotEmpty, isTrue);
      expect(alertProvider.hasCriticalAlerts, isTrue);

      // Filter by severity
      await alertProvider.setSeverityFilter('critical');
      expect(alertProvider.alerts.every((a) => a.severity.toLowerCase() == 'critical'), isTrue);

      // Update commuter alert subscription preferences
      final updatedSub = await alertProvider.updateSubscription(
        userId: 1,
        subscriptionType: 'geo_radius',
        centerLatitude: 6.9271,
        centerLongitude: 79.8612,
        radiusKm: 7.5,
        pushNotificationsEnabled: true,
        weatherAlerts: true,
        roadHazards: true,
        transitDisruptions: true,
        soundAndVibrate: true,
      );
      expect(updatedSub, isTrue);
      expect(alertProvider.subscription, isNotNull);
      expect(alertProvider.subscription!.radiusKm, equals(7.5));
      expect(alertProvider.subscription!.subscriptionType, equals('geo_radius'));

      // Register device FCM token
      final registered = await alertProvider.registerDeviceToken(
        userId: 1,
        fcmToken: 'fcm_sample_commuter_device_token_xyz123',
        deviceType: 'android',
      );
      expect(registered, isTrue);
    });

    test('17. MapProvider incident filtering, search, and selection (Thimaya)', () async {
      final mapProvider = MapProvider();

      await mapProvider.loadMapData();
      expect(mapProvider.incidents.isNotEmpty, isTrue);

      // Test filtering by incident type
      mapProvider.setTypeFilter('flooding');
      expect(mapProvider.filteredIncidents.every((i) => i.incidentType.toLowerCase() == 'flooding'), isTrue);

      // Test reset and search query
      mapProvider.setTypeFilter('All');
      mapProvider.setSearchQuery('Kollupitiya');
      expect(mapProvider.filteredIncidents.any((i) => i.addressText.contains('Kollupitiya')), isTrue);

      // Test incident selection for bottom preview sheet
      final firstIncident = mapProvider.incidents.first;
      mapProvider.selectIncident(firstIncident);
      expect(mapProvider.selectedIncident, isNotNull);
      expect(mapProvider.selectedIncident!.id, equals(firstIncident.id));

      mapProvider.clearSelectedIncident();
      expect(mapProvider.selectedIncident, isNull);
    });
  });
}
