import 'package:flutter/material.dart';

/// TravelPulse LK — Design System Color Palette
/// Matches the Figma design reference for TravelPulse LK.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Figma Design Token: #1F6F7C)
  static const Color primary = Color(0xFF1F6F7C);
  static const Color primaryDark = Color(0xFF16525C);
  static const Color primaryLight = Color(0xFFE5F1F3);
  static const Color primaryContainer = Color(0xFFD6EAEF);
  
  static const Color secondary = Color(0xFF2E8B99); // Supporting Teal Accent
  static const Color secondaryDark = Color(0xFF1E5E68);
  static const Color secondaryLight = Color(0xFFE8F5F7);

  // Functional / Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Verified reports, clear roads
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B); // Delays, moderate crowds
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444); // Critical alerts, road closures
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6); // Informational alerts
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);

  // Crowd Density Specific Colors
  static const Color crowdEmpty = Color(0xFF10B981);     // Low / Plenty of seats
  static const Color crowdModerate = Color(0xFF3B82F6);  // Normal / Standing available
  static const Color crowdCrowded = Color(0xFFF59E0B);   // Heavy / Standing only
  static const Color crowdPacked = Color(0xFFEF4444);    // Packed / Hard to board

  // Neutral Background & Surface Colors (Figma Design Token: #F7FBFC)
  static const Color background = Color(0xFFF7FBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF5F8);
  static const Color card = Color(0xFFFFFFFF);

  // Text & Content Colors (Figma Design Tokens: #152238 & #526C77)
  static const Color textPrimary = Color(0xFF152238);
  static const Color textSecondary = Color(0xFF526C77);
  static const Color textMuted = Color(0xFF8B9FA8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Border & Divider Colors
  static const Color border = Color(0xFFE2EBEF);
  static const Color borderLight = Color(0xFFEDF4F7);
  static const Color borderDark = Color(0xFFCAD7DD);
  static const Color divider = Color(0xFFE2EBEF);

  // Shadows
  static const Color shadow = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);

  // Operator Badges
  static const Color operatorSltb = Color(0xFFDC2626); // SLTB Red
  static const Color operatorPrivate = Color(0xFF0284C7); // Private Blue
  static const Color operatorTrain = Color(0xFF059669); // Railway Green
}
