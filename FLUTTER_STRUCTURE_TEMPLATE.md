# Flutter Project Structure Template
## Exact scaffolding needed for all 4 apps

This template shows the EXACT file structure and file organization required for:
- pos-kasir
- backoffice  
- user-apk
- dashboard-admin

Each app should have this structure. App-specific differences are noted.

---

## UNIVERSAL STRUCTURE (ALL 4 APPS)

```
lib/
├── main.dart                                    # ENTRY POINT
├── app.dart                                     # NEW: MaterialApp wrapper
│
├── core/                                        # SHARED utilities (ALL apps)
│   ├── constants/
│   │   ├── app_colors.dart                      # (move from theme/)
│   │   ├── app_typography.dart                  # NEW: extracted from app_theme
│   │   ├── app_spacing.dart                     # NEW: extracted from app_theme
│   │   └── app_shadows.dart                     # NEW: extracted from app_theme
│   │
│   ├── theme/
│   │   ├── app_theme.dart                       # (exists, refactor to use constants/)
│   │   └── theme_extensions.dart                # NEW: for custom theme extensions
│   │
│   ├── network/                                 # NEW: API integration
│   │   ├── api_client.dart                      # Dio singleton
│   │   ├── api_config.dart                      # BASE_URL, timeouts
│   │   ├── auth_interceptor.dart                # Attach token to requests
│   │   └── error_mapper.dart                    # Map HTTP errors to messages
│   │
│   ├── storage/                                 # NEW: Persistence layer
│   │   ├── storage_keys.dart                    # Constants for SecureStorage keys
│   │   └── secure_storage.dart                  # Read/write tokens, user data
│   │
│   ├── utils/                                   # NEW: Helpers
│   │   ├── currency_formatter.dart              # Format to IDR
│   │   ├── date_formatter.dart                  # Format dates/times
│   │   ├── validators.dart                      # Input validation (email, phone, etc)
│   │   └── responsive.dart                      # NEW: AppBreakpoints & helpers
│   │
│   └── widgets/                                 # NEW: Reusable component library
│       ├── app_button.dart                      # PRIMARY, SECONDARY, TERTIARY
│       ├── app_card.dart                        # Base card with soft shadow
│       ├── app_text_field.dart                  # Base input field
│       ├── loading_overlay.dart                 # Full-screen loading
│       ├── error_view.dart                      # Error state UI
│       ├── empty_view.dart                      # Empty state UI
│       ├── status_badge.dart                    # Color-coded status badge
│       └── responsive_layout.dart               # LayoutBuilder wrapper
│
├── features/                                    # NEW: Feature modules
│   ├── auth/                                    # Universal across all apps
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   ├── models/
│   │   │   └── login_request.dart
│   │   ├── auth_provider.dart                   # State management
│   │   ├── login_screen.dart
│   │   ├── logout_dialog.dart
│   │   └── token_expiry_dialog.dart
│   │
│   └── [app-specific features]                  # See below per app
│
├── models/                                      # NEW: Shared domain models
│   ├── user_model.dart
│   ├── branch_model.dart
│   ├── [any cross-feature models]
│   └── ...
│
└── routes/                                      # NEW: Navigation setup
    ├── app_router.dart                          # GoRouter configuration
    └── route_names.dart                         # Named route constants

```

---

## APP-SPECIFIC STRUCTURES

### 1. pos-kasir (POS Cashier)

Add to `features/`:

```
features/
├── auth/                        # Universal
│
├── home/                        # NEW: Dashboard after login
│   ├── home_provider.dart
│   └── home_screen.dart
│
├── pos/                         # NEW: Main POS screen
│   ├── data/
│   │   └── pos_repository.dart
│   ├── models/
│   │   ├── order_model.dart
│   │   ├── cart_item_model.dart
│   │   └── payment_model.dart
│   ├── widgets/
│   │   ├── category_grid.dart       # Grid of item categories
│   │   ├── item_grid.dart           # Grid of selectable items
│   │   ├── cart_item_tile.dart      # Item in cart/order
│   │   ├── payment_dialog.dart      # Payment confirmation
│   │   ├── pos_keypad.dart          # Numeric keypad for quantity
│   │   └── order_summary_panel.dart # Cart summary on side/bottom
│   ├── pos_provider.dart            # State: currentOrder, cartItems
│   └── pos_screen.dart              # Main POS screen
│
├── orders/                      # NEW: Order history
│   ├── order_history_screen.dart
│   ├── order_detail_screen.dart
│   ├── orders_provider.dart
│   └── models/
│       └── order_list_item.dart
│
└── kitchen/                     # NEW: Kitchen display system
    ├── kitchen_screen.dart
    ├── kitchen_provider.dart
    └── models/
        └── kitchen_order.dart
```

### 2. backoffice (BackOffice Management)

Add to `features/`:

```
features/
├── auth/                        # Universal
│
├── dashboard/                   # NEW: Executive summary
│   ├── dashboard_screen.dart
│   ├── dashboard_provider.dart
│   └── widgets/
│       ├── sales_card.dart
│       ├── top_items_widget.dart
│       └── shift_status_widget.dart
│
├── master/                      # NEW: Master data management
│   ├── categories/
│   │   ├── category_list_screen.dart
│   │   ├── category_form_screen.dart
│   │   ├── category_provider.dart
│   │   └── models/
│   │       └── category_model.dart
│   ├── items/
│   │   ├── item_list_screen.dart
│   │   ├── item_form_screen.dart
│   │   ├── item_provider.dart
│   │   └── models/
│   │       └── item_model.dart
│   ├── modifiers/
│   │   ├── modifier_list_screen.dart
│   │   └── modifier_form_screen.dart
│   └── tables/
│       ├── table_list_screen.dart
│       └── table_form_screen.dart
│
├── employees/                   # NEW: Staff management
│   ├── employee_list_screen.dart
│   ├── employee_form_screen.dart
│   ├── employee_provider.dart
│   └── models/
│       └── employee_model.dart
│
├── inventory/                   # NEW: Stock management
│   ├── stock_screen.dart
│   ├── purchase_screen.dart
│   ├── inventory_provider.dart
│   ├── widgets/
│   │   └── responsive_stock_table.dart
│   └── models/
│       ├── stock_item.dart
│       └── purchase_order.dart
│
├── reports/                     # NEW: Analytics & reports
│   ├── sales_report_screen.dart
│   ├── shift_report_screen.dart
│   ├── reports_provider.dart
│   ├── widgets/
│   │   ├── sales_chart.dart
│   │   └── performance_card.dart
│   └── models/
│       └── report_data.dart
│
└── profile/                     # NEW: Branch/staff profile
    ├── profile_screen.dart
    └── profile_provider.dart
```

**BackOffice-Specific Widgets (add to core/widgets/):**
```
core/widgets/
├── app_button.dart              # Universal
├── app_card.dart                # Universal
├── app_text_field.dart          # Universal
├── navigation_rail.dart         # NEW: BackOffice navigation
├── responsive_table.dart        # NEW: Convert to cards at compact
└── [other universal widgets]
```

### 3. user-apk (Customer App)

Add to `features/`:

```
features/
├── auth/                        # Universal
│
├── menu/                        # NEW: Menu browsing
│   ├── menu_screen.dart
│   ├── menu_provider.dart
│   ├── widgets/
│   │   ├── category_tabs.dart   # Top tabs for categories
│   │   ├── item_grid.dart       # Product grid with images
│   │   ├── item_card.dart       # Single product card
│   │   └── item_detail_bottom_sheet.dart
│   └── models/
│       ├── menu_item.dart
│       └── category.dart
│
├── cart/                        # NEW: Shopping cart
│   ├── cart_screen.dart
│   ├── cart_provider.dart
│   ├── widgets/
│   │   ├── cart_item_tile.dart
│   │   └── checkout_button.dart
│   └── models/
│       └── cart_item.dart
│
├── orders/                      # NEW: Order management
│   ├── order_history_screen.dart
│   ├── order_detail_screen.dart
│   ├── order_tracking_screen.dart
│   ├── orders_provider.dart
│   ├── widgets/
│   │   ├── order_status_timeline.dart
│   │   └── order_card.dart
│   └── models/
│       └── order_model.dart
│
├── favorites/                   # NEW: Saved items
│   ├── favorites_screen.dart
│   ├── favorites_provider.dart
│   └── widgets/
│       └── favorite_item_grid.dart
│
└── addresses/                   # NEW: Delivery addresses
    ├── address_list_screen.dart
    ├── address_form_screen.dart
    ├── address_provider.dart
    └── models/
        └── address_model.dart
```

**User APK-Specific Widgets (add to core/widgets/):**
```
core/widgets/
├── [all universal widgets]
├── image_grid.dart              # NEW: Consistent aspect ratio grid
└── product_image_card.dart      # NEW: 1:1 or 4:3 image card
```

### 4. dashboard-admin (Cross-Branch Dashboard)

Add to `features/`:

```
features/
├── auth/                        # Universal
│
├── overview/                    # NEW: Cross-branch summary
│   ├── overview_screen.dart
│   ├── overview_provider.dart
│   ├── widgets/
│   │   ├── kpi_card.dart                # Key performance indicator
│   │   ├── branch_comparison_chart.dart
│   │   └── trend_widget.dart
│   └── models/
│       └── overview_metrics.dart
│
├── branches/                    # NEW: Branch management
│   ├── branch_list_screen.dart
│   ├── branch_detail_screen.dart
│   ├── branch_form_screen.dart
│   ├── branches_provider.dart
│   └── models/
│       └── branch_model.dart
│
├── reports/                     # NEW: Comparative analytics
│   ├── sales_comparison_screen.dart
│   ├── branch_performance_screen.dart
│   ├── reports_provider.dart
│   ├── widgets/
│   │   ├── sales_comparison_chart.dart
│   │   └── performance_table.dart
│   └── models/
│       └── branch_report.dart
│
└── audit/                       # NEW: Audit logs
    ├── audit_log_screen.dart
    ├── audit_provider.dart
    └── models/
        └── audit_entry.dart
```

**Dashboard-Specific Utilities (add to core/utils/):**
```
core/utils/
├── [all universal utilities]
└── chart_theme.dart             # NEW: Chart color theming
```

---

## CRITICAL FILE TEMPLATES

### 1. main.dart (REFACTORED)

```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  // Initialize dependencies here
  // runApp(App()) will handle the rest
  runApp(const App());
}
```

### 2. app.dart (NEW - REQUIRED)

```dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart'; // After router setup

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Title Here',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // router: AppRouter.router,  // Uncomment after GoRouter setup
      // Will handle home: const HomePage(); for now
    );
  }
}
```

### 3. responsive.dart (NEW - REQUIRED)

```dart
import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 1024;
  static const double expanded = 1440;

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

  static double getMaxWidth(BuildContext context) {
    if (isCompact(context)) return double.infinity;
    if (isMedium(context)) return 600;
    if (isExpanded(context)) return 900;
    return 1200;
  }
}
```

### 4. app_button.dart (NEW - REQUIRED)

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;

  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(),
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(),
        ),
      AppButtonVariant.tertiary => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(),
        ),
    };
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Text(label);
  }
}

enum AppButtonVariant { primary, secondary, tertiary }
```

### 5. app_card.dart (NEW - REQUIRED)

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_shadows.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({
    required this.child,
    this.padding,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.x4),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [AppShadows.sm],
        ),
        child: child,
      ),
    );
  }
}
```

### 6. app_text_field.dart (NEW - REQUIRED)

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;

  const AppTextField({
    this.label,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    super.key,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
```

### 7. app_colors.dart (RELOCATE from theme/)

```dart
// Move from lib/theme/ to lib/core/constants/
// Content stays the same
```

### 8. app_spacing.dart (EXTRACT from theme/)

```dart
// Extract AppSpacing class from app_theme.dart into separate file
// lib/core/constants/app_spacing.dart

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
```

### 9. app_shadows.dart (EXTRACT from theme/)

```dart
// Extract AppShadows class from app_theme.dart into separate file
// lib/core/constants/app_shadows.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

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

### 10. app_theme.dart (REFACTOR - use constants/)

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_shadows.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      // ... rest stays the same, but imports constants/
    );
  }
}
```

---

## FILE CHECKLIST FOR ALL 4 APPS

### Phase 0: Foundation (Days 1-2)

**Files to Create:**
- [ ] lib/app.dart
- [ ] lib/core/ (directory)
- [ ] lib/core/constants/app_colors.dart (move from theme/)
- [ ] lib/core/constants/app_spacing.dart (extract from theme/)
- [ ] lib/core/constants/app_shadows.dart (extract from theme/)
- [ ] lib/core/constants/app_typography.dart (new)
- [ ] lib/core/theme/app_theme.dart (refactor to use constants/)
- [ ] lib/core/theme/theme_extensions.dart
- [ ] lib/core/utils/responsive.dart
- [ ] lib/core/utils/currency_formatter.dart
- [ ] lib/core/utils/date_formatter.dart
- [ ] lib/core/utils/validators.dart
- [ ] lib/core/widgets/app_button.dart
- [ ] lib/core/widgets/app_card.dart
- [ ] lib/core/widgets/app_text_field.dart
- [ ] lib/core/widgets/loading_overlay.dart
- [ ] lib/core/widgets/error_view.dart
- [ ] lib/core/widgets/empty_view.dart
- [ ] lib/core/widgets/status_badge.dart
- [ ] lib/core/widgets/responsive_layout.dart

**Files to Modify:**
- [ ] lib/main.dart (simplify)
- [ ] lib/theme/app_theme.dart (refactor)

### Phase 1: Infrastructure (Days 3-5)

- [ ] lib/core/network/api_client.dart
- [ ] lib/core/network/api_config.dart
- [ ] lib/core/network/auth_interceptor.dart
- [ ] lib/core/network/error_mapper.dart
- [ ] lib/core/storage/storage_keys.dart
- [ ] lib/core/storage/secure_storage.dart
- [ ] lib/routes/route_names.dart
- [ ] lib/routes/app_router.dart
- [ ] lib/features/auth/ (complete structure)
- [ ] lib/models/ (shared models)

### Phase 2: App-Specific (Days 6+)

- [ ] lib/features/ (create app-specific feature folders per app above)

---

## DONE CHECKLIST

After implementing this template:

- [ ] All 4 apps have identical core/ structure
- [ ] All 4 apps have app.dart wrapper
- [ ] All shared widgets are working
- [ ] AppBreakpoints is accessible everywhere
- [ ] Features are organized properly
- [ ] No hardcoded colors/spacing/shadows anywhere
- [ ] No duplicate code between apps
- [ ] File naming is consistent (snake_case)
- [ ] 1 file = 1 class rule enforced

---

**This template is REQUIRED before proceeding with feature development.**
