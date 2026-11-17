import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TravelPulse LK — Design System Spacing & Dimensions
/// Defines consistent layout metrics, border radii, and shadows.
class AppSpacing {
  AppSpacing._();

  // Spacing Units
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // Standard Screen Gutters
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
  static const EdgeInsets horizontalScreen = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets compactCardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets modalPadding = EdgeInsets.all(24.0);

  // Border Radii
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;
  static const double radiusPill = 999.0;

  static final BorderRadius roundedSm = BorderRadius.circular(radiusSm);
  static final BorderRadius roundedMd = BorderRadius.circular(radiusMd);
  static final BorderRadius roundedLg = BorderRadius.circular(radiusLg);
  static final BorderRadius roundedXl = BorderRadius.circular(radiusXl);
  static final BorderRadius roundedPill = BorderRadius.circular(radiusPill);

  // Component Heights
  static const double buttonHeight = 48.0;
  static const double inputHeight = 50.0;
  static const double bottomNavHeight = 64.0;

  // Box Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 10.0,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 16.0,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24.0,
      offset: Offset(0, -4),
      spreadRadius: 0,
    ),
  ];
}
