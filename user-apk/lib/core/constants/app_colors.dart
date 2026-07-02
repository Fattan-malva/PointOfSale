import 'package:flutter/material.dart';

/// Design Tokens — Warna
/// Basis: Black & White dengan satu aksen (Biru Indigo)
class AppColors {
  // Netral (Black & White)
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F8);
  static const Color surfaceRaised = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E7EA);
  static const Color textPrimary = Color(0xFF111113);
  static const Color textSecondary = Color(0xFF5C5C63);
  static const Color textDisabled = Color(0xFFA8A8AE);
  static const Color inverseBg = Color(0xFF111113);
  static const Color inverseText = Color(0xFFFFFFFF);

  // Aksen (Biru Indigo)
  static const Color accent = Color(0xFF2F6FED);
  static const Color accentSoft = Color(0xFFEAF0FE);
  static const Color accentPressed = Color(0xFF2456C4);

  // Semantik
  static const Color success = Color(0xFF1E9E5A);
  static const Color successSoft = Color(0xFFE7F7EE);
  static const Color warning = Color(0xFFC77700);
  static const Color warningSoft = Color(0xFFFDF1DF);
  static const Color error = Color(0xFFD6314B);
  static const Color errorSoft = Color(0xFFFBE7EA);

  // Dark Mode (Future)
  static const Color darkBg = Color(0xFF111113);
  static const Color darkSurface = Color(0xFF1F1F23);
  static const Color darkTextPrimary = Color(0xFFF5F5F6);
  static const Color darkTextSecondary = Color(0xFFA8A8AE);
}
