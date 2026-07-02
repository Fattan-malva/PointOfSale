import 'package:flutter/material.dart';

/// Responsive Design System - Breakpoints
/// Berdasarkan Material Design 3 adaptive layout
class AppBreakpoints {
  final BuildContext context;
  const AppBreakpoints._(this.context);
  static AppBreakpoints of(BuildContext context) => AppBreakpoints._(context);
  bool get isCompact => MediaQuery.of(context).size.width < compactMax;
  bool get isMedium => MediaQuery.of(context).size.width >= compactMax && MediaQuery.of(context).size.width < mediumMax;
  bool get isExpanded => MediaQuery.of(context).size.width >= mediumMax && MediaQuery.of(context).size.width < expandedMax;
  bool get isLarge => MediaQuery.of(context).size.width >= expandedMax;

  // Breakpoints (dalam dp/logical pixels)
  static const double compact = 0; // < 600
  static const double compactMax = 600;
  static const double medium = 600; // 600 - 1023
  static const double mediumMax = 1024;
  static const double expanded = 1024; // 1024 - 1439
  static const double expandedMax = 1440;
  static const double large = 1440; // >= 1440

  /// Helper untuk menentukan breakpoint saat ini
  static AppBreakpoint getBreakpoint(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < compactMax) {
      return AppBreakpoint.compact;
    } else if (width < mediumMax) {
      return AppBreakpoint.medium;
    } else if (width < expandedMax) {
      return AppBreakpoint.expanded;
    } else {
      return AppBreakpoint.large;
    }
  }

  /// Helper untuk cek apakah di desktop (expanded atau lebih besar)
  static bool isDesktop(BuildContext context) =>
      getBreakpoint(context).index >= AppBreakpoint.expanded.index;

  /// Helper untuk cek apakah di tablet atau lebih besar
  static bool isTabletOrLarger(BuildContext context) =>
      getBreakpoint(context).index >= AppBreakpoint.medium.index;
}

enum AppBreakpoint { compact, medium, expanded, large }
