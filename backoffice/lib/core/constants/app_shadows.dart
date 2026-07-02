import 'package:flutter/material.dart';

/// Design Tokens — Shadow (Soft UI)
/// Bayangan lembut, difus, dengan opacity rendah
class AppShadows {
  // XS: Border pengganti pada elemen datar
  static const BoxShadow xs = BoxShadow(
    color: Color.fromRGBO(17, 17, 19, 0.04),
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
  );

  // SM: List item, input focus
  static const BoxShadow sm = BoxShadow(
    color: Color.fromRGBO(17, 17, 19, 0.06),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );

  // MD: Card standar
  static const BoxShadow md = BoxShadow(
    color: Color.fromRGBO(17, 17, 19, 0.08),
    offset: Offset(0, 6),
    blurRadius: 16,
    spreadRadius: 0,
  );

  // LG: Modal, FAB, bottom sheet
  static const BoxShadow lg = BoxShadow(
    color: Color.fromRGBO(17, 17, 19, 0.10),
    offset: Offset(0, 12),
    blurRadius: 28,
    spreadRadius: 0,
  );

  // List dari semua shadow (untuk mudah dipakai)
  static const List<BoxShadow> xsList = [xs];
  static const List<BoxShadow> smList = [sm];
  static const List<BoxShadow> mdList = [md];
  static const List<BoxShadow> lgList = [lg];
}
