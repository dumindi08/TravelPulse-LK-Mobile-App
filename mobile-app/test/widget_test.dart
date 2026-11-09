import 'package:flutter_test/flutter_test.dart';
import 'package:travelpulse_mobile/app.dart';
import 'package:travelpulse_mobile/modules/nisal/providers/auth_provider.dart';

void main() {
  testWidgets('TravelPulse LK onboarding smoke test', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    // Build the TravelPulseApp root widget
    await tester.pumpWidget(TravelPulseApp(authProvider: authProvider));
    await tester.pumpAndSettle();

    // Verify Welcome view brand headline and action buttons render
    expect(find.text('TravelPulse LK'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
