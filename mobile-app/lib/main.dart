import 'package:flutter/material.dart';
import 'app.dart';
import 'modules/nisal/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  runApp(TravelPulseApp(authProvider: authProvider));
}
