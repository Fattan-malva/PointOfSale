import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F7F8);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const border = Color(0xFFE7E7EA);
  static const textPrimary = Color(0xFF111113);
  static const textSecondary = Color(0xFF5C5C63);
  static const textDisabled = Color(0xFFA8A8AE);
  static const inverseBg = Color(0xFF111113);
  static const inverseText = Color(0xFFFFFFFF);

  static const accent = Color(0xFF2F6FED);
  static const accentSoft = Color(0xFFEAF0FE);
  static const accentPressed = Color(0xFF2456C4);

  static const success = Color(0xFF1E9E5A);
  static const successSoft = Color(0xFFE7F7EE);
  static const warning = Color(0xFFC77700);
  static const warningSoft = Color(0xFFFDF1DF);
  static const error = Color(0xFFD6314B);
  static const errorSoft = Color(0xFFFBE7EA);
}

class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

class AppSpacing {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;
}

class AppShadows {
  static const xs = BoxShadow(
    color: Color(0x0A111113),
    offset: Offset(0, 1),
    blurRadius: 2,
  );

  static const sm = BoxShadow(
    color: Color(0x0F111113),
    offset: Offset(0, 2),
    blurRadius: 8,
  );

  static const md = BoxShadow(
    color: Color(0x14111113),
    offset: Offset(0, 6),
    blurRadius: 16,
  );

  static const lg = BoxShadow(
    color: Color(0x1A111113),
    offset: Offset(0, 12),
    blurRadius: 28,
  );
}
