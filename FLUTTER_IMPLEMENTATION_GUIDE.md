# Flutter Audit — Implementation Guide

**Status:** Ready to start  
**Timeline:** 2.5 weeks to Phase 3 (Ready for Features)  
**Team:** Minimum 1 developer (with 2 developers can parallelize)

---

## Overview

This guide walks through implementing the audit recommendations in the right order. **Do NOT skip steps** — each layer builds on previous ones.

### Why This Order?
1. **Foundation first** — Sets up the container everything else sits in
2. **Infrastructure next** — Network, storage, state management
3. **Features last** — Building features ON TOP of solid foundation

**If you build features first, you'll rewrite them all when you add infrastructure later.**

---

## Phase 0: Foundation (Days 1-2)

### Goal
Create the basic folder structure and extract design tokens so they're reusable.

### Step-by-Step

#### Step 1: Separate main.dart → app.dart
**For each app (pos-kasir, backoffice, user-apk, dashboard-admin):**

**File: lib/app.dart** (NEW)
```dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Title Here',  // Change per app
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(child: Text('TODO: Add routing')),
      ),
    );
  }
}
```

**File: lib/main.dart** (MODIFY)
```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const App());
}
```

**Check:**
- [ ] Apps still run and show "TODO: Add routing"
- [ ] No errors in console

---

#### Step 2: Create core/ directory structure
**For each app:**

Create these directories:
```
lib/core/
├── constants/
├── theme/
├── network/
├── storage/
├── utils/
└── widgets/
```

Commands:
```powershell
# In pos-kasir/
mkdir lib\core\constants
mkdir lib\core\theme
mkdir lib\core\network
mkdir lib\core\storage
mkdir lib\core\utils
mkdir lib\core\widgets

# Repeat for backoffice/, user-apk/, dashboard-admin/
```

**Check:**
- [ ] All directories created
- [ ] No files yet, just folders

---

#### Step 3: Move app_colors.dart
**For each app:**

1. Cut: `lib/theme/app_colors.dart`
2. Paste to: `lib/core/constants/app_colors.dart`
3. Delete empty `lib/theme/` directory (we'll recreate it)

**Check:**
- [ ] File moved successfully
- [ ] app_colors.dart is in lib/core/constants/

---

#### Step 4: Extract app_spacing.dart, app_shadows.dart
**For each app:**

From `lib/theme/app_theme.dart`, extract:

**File: lib/core/constants/app_spacing.dart** (NEW)
```dart
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

class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}
```

**File: lib/core/constants/app_shadows.dart** (NEW)
```dart
import 'package:flutter/material.dart';

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
```

From `lib/theme/app_theme.dart`, REMOVE the `AppSpacing`, `AppRadius`, `AppShadows` class definitions.

**Check:**
- [ ] New files created
- [ ] app_theme.dart no longer has these classes
- [ ] No import errors

---

#### Step 5: Create app_typography.dart
**For each app:**

**File: lib/core/constants/app_typography.dart** (NEW)

From `lib/theme/app_theme.dart`, extract the `textTheme` TextStyle definitions:

```dart
import 'package:flutter/material.dart';

class AppTypography {
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
```

**Check:**
- [ ] File created
- [ ] All typography styles present

---

#### Step 6: Refactor app_theme.dart
**For each app:**

Modify `lib/theme/app_theme.dart` to use the extracted constants:

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_shadows.dart';
import '../constants/app_typography.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,

      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.accentSoft,
        onSecondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
      ),

      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelMedium: AppTypography.labelMedium,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x6,
            vertical: AppSpacing.x4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x6,
            vertical: AppSpacing.x4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceRaised,
        elevation: 0,
        shadowColor: AppColors.textPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: const EdgeInsets.all(0),
      ),

      chipTheme: ChipThemeData(
        shape: StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x1,
        ),
        labelStyle: const TextStyle(fontSize: 12),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bg,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
```

**Check:**
- [ ] All imports correct
- [ ] App runs without errors
- [ ] Styling unchanged

---

#### Step 7: Create responsive.dart
**For each app:**

**File: lib/core/utils/responsive.dart** (NEW)

```dart
import 'package:flutter/material.dart';

/// Breakpoint constants aligned with Design.md §7.1
abstract class AppBreakpoints {
  static const double compact = 600;      // < 600dp
  static const double medium = 1024;      // 600-1023dp
  static const double expanded = 1440;    // 1024-1439dp

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < compact;

  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width >= compact &&
      MediaQuery.of(context).size.width < medium;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width >= medium &&
      MediaQuery.of(context).size.width < expanded;

  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= expanded;

  /// Get appropriate max width for content container
  static double getMaxWidth(BuildContext context) {
    if (isLarge(context)) return 1200;
    if (isExpanded(context)) return 900;
    if (isMedium(context)) return 600;
    return double.infinity;
  }

  /// Get number of columns for grid layout
  static int getGridColumns(BuildContext context) {
    if (isLarge(context)) return 4;
    if (isExpanded(context)) return 3;
    if (isMedium(context)) return 2;
    return 1;
  }
}
```

**Check:**
- [ ] File created
- [ ] No import errors

---

#### Step 8: Create core/widgets/ stub files
**For each app:**

Create these files (content can be basic for now):

**lib/core/widgets/app_button.dart**
```dart
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppButton({
    required this.label,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
```

Create similar stubs for:
- [ ] lib/core/widgets/app_card.dart
- [ ] lib/core/widgets/app_text_field.dart
- [ ] lib/core/widgets/loading_overlay.dart
- [ ] lib/core/widgets/error_view.dart
- [ ] lib/core/widgets/empty_view.dart
- [ ] lib/core/widgets/status_badge.dart
- [ ] lib/core/widgets/responsive_layout.dart

**Check:**
- [ ] All files created
- [ ] No import errors when running app

---

#### Step 9: Create features/ & models/ directories
**For each app:**

```powershell
# For pos-kasir
mkdir lib\features
mkdir lib\models

# Repeat for all 4 apps
```

Also create app-specific feature directories (see FLUTTER_STRUCTURE_TEMPLATE.md):

```powershell
# pos-kasir
mkdir lib\features\auth
mkdir lib\features\pos
mkdir lib\features\orders
mkdir lib\features\kitchen

# backoffice
mkdir lib\features\auth
mkdir lib\features\dashboard
mkdir lib\features\master
mkdir lib\features\employees
mkdir lib\features\inventory
mkdir lib\features\reports

# user-apk
mkdir lib\features\auth
mkdir lib\features\menu
mkdir lib\features\cart
mkdir lib\features\orders
mkdir lib\features\favorites
mkdir lib\features\addresses

# dashboard-admin
mkdir lib\features\auth
mkdir lib\features\overview
mkdir lib\features\branches
mkdir lib\features\reports
mkdir lib\features\audit
```

**Check:**
- [ ] All directories created

---

### Phase 0 Verification

After Phase 0, each app should have:

```
lib/
├── main.dart                    ✅ Simplified
├── app.dart                     ✅ NEW
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      ✅
│   │   ├── app_spacing.dart     ✅
│   │   ├── app_shadows.dart     ✅
│   │   └── app_typography.dart  ✅
│   ├── theme/
│   │   └── app_theme.dart       ✅ Refactored
│   ├── utils/
│   │   └── responsive.dart      ✅
│   ├── network/                 (empty)
│   ├── storage/                 (empty)
│   └── widgets/
│       ├── app_button.dart      ✅ Stub
│       ├── app_card.dart        ✅ Stub
│       └── ... (all 7 stubs)
├── features/
│   ├── auth/                    (empty)
│   └── [app-specific]           (empty)
└── models/                      (empty)
```

**Tests:**
- [ ] `flutter pub get` works
- [ ] `flutter run` works
- [ ] App displays UI
- [ ] No errors in console
- [ ] All 4 apps have same structure

**Time estimate:** 6-8 hours for 1 developer (parallelizable)

---

## Phase 1: Infrastructure (Days 3-5)

### Goal
Set up network layer, routing, and state management foundation.

### Prerequisites
- [ ] All Phase 0 tasks complete
- [ ] All 4 apps running without errors

### Key Tasks

#### Task 1: Add pubspec dependencies
Update `pubspec.yaml` for each app:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Network
  dio: ^5.4.0
  
  # Storage
  flutter_secure_storage: ^9.0.0
  
  # Routing
  go_router: ^14.0.0
  
  # State management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  
  # Utilities
  intl: ^0.19.0
```

Run: `flutter pub get` for each app

#### Task 2: Set up routing
Create `lib/routes/route_names.dart` and `lib/routes/app_router.dart` (see template)

#### Task 3: Implement API client
Create `lib/core/network/` files with Dio setup

#### Task 4: Set up secure storage
Create `lib/core/storage/` files

#### Task 5: Create feature/auth/ structure
Set up authentication foundation for all apps

**Time estimate:** 5-7 days

---

## Phase 2: Features (Days 6+)

### Goal
Build app-specific features using solid foundation.

By now:
- ✅ Core structure is solid
- ✅ Routing works
- ✅ Network layer works
- ✅ State management works

Now you can build features without rework!

---

## Success Metrics

After Phase 0:
- ✅ All 4 apps have identical core/ structure
- ✅ Design tokens are reusable
- ✅ AppBreakpoints is accessible everywhere
- ✅ No hardcoded values

After Phase 1:
- ✅ Apps can navigate between screens
- ✅ API client can connect to backend
- ✅ Tokens are stored securely
- ✅ State management works

After Phase 2:
- ✅ All features implemented
- ✅ Apps are responsive
- ✅ No duplicate code
- ✅ Maintainable codebase

---

## Common Mistakes to Avoid

❌ **DON'T:**
- Build features before Phase 0 is done
- Skip refactoring — it's not optional
- Hardcode values instead of using tokens
- Create duplicate widgets across apps

✅ **DO:**
- Follow this order exactly
- Test after each step
- Keep files small (1 class per file)
- Use shared core/ for all apps

---

## Need Help?

1. **Reference:** FLUTTER_STRUCTURE_TEMPLATE.md
2. **Audit:** FLUTTER_AUDIT_REPORT.md  
3. **Quick Ref:** FLUTTER_AUDIT_QUICK_REF.md
4. **Design Rules:** Design.md section 10

---

**Ready to start?** Begin with Phase 0, Step 1.
