import 'package:flutter/material.dart';

/// Design Tokens — Tipografi
/// Font: Menggunakan sistem font default (akan diganti dengan custom font sesuai kebutuhan)
/// Family: Plus Jakarta Sans (atau sesuai keputusan tim)
class AppTypography {
  // Display: 28-32sp, Bold (700)
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // Title: 20-22sp, SemiBold (600)
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  // Body Large: 16sp, Regular (400)
  static const TextStyle bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  // Body: 14sp, Regular (400)
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  // Caption: 12sp, Regular/Medium (500)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  // Numeric: Tabular figures untuk alignment rapi
  static const TextStyle numeric = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle numericLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle numericXl = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // H1: 24-28sp, Bold
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // H2: 20-22sp, SemiBold
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  // H3: 18sp, SemiBold
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // H4: 16sp, SemiBold
  static const TextStyle h4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
}
