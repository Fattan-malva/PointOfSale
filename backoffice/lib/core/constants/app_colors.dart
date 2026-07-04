import 'package:flutter/material.dart';

/// Design Tokens — Warna
/// Basis: Black & White dengan satu aksen (Biru Indigo)
class AppColors {
  // Netral (Black & White)
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111113);
  static const Color textSecondary = Color(0xFF5C5C63);
  static const Color textDisabled = Color(0xFFA8A8AE);
  static const Color inverseBg = Color(0xFF111113);
  static const Color inverseText = Color(0xFFFFFFFF);

  // Aksen black & white
  static const Color accent = Color.fromARGB(255, 1, 5, 13);
  static const Color accentSoft = Color(0xFFEAF0FE);
  static const Color accentPressed = Color.fromARGB(255, 2, 4, 9);

  // Semantik
  static const Color success = Color(0xFF1E9E5A);
  static const Color info = Color(0xFF0284C7);
  static const Color infoSoft = Color(0xFFE5F4FF);
  static const Color successSoft = Color(0xFFE7F7EE);
  static const Color warning = Color(0xFFC77700);
  static const Color warningSoft = Color(0xFFFDF1DF);
  static const Color error = Color(0xFFD6314B);
  static const Color errorSoft = Color(0xFFFBE7EA);

  // Muted Pastels (Premium Utilitarian Minimalism)
  static const Color pastelRed = Color(0xFFFDEBEC);
  static const Color pastelRedText = Color(0xFF9F2F2D);
  static const Color pastelBlue = Color(0xFFE1F3FE);
  static const Color pastelBlueText = Color(0xFF1F6C9F);
  static const Color pastelGreen = Color(0xFFEDF3EC);
  static const Color pastelGreenText = Color(0xFF346538);
  static const Color pastelYellow = Color(0xFFFBF3DB);
  static const Color pastelYellowText = Color(0xFF956400);
  static const Color warmBone = Color(0xFFF7F6F3);

  // Dark Mode (Future)
  static const Color darkBg = Color(0xFF111113);
  static const Color darkSurface = Color(0xFF1F1F23);
  static const Color darkTextPrimary = Color(0xFFF5F5F6);
  static const Color darkTextSecondary = Color(0xFFA8A8AE);
}
