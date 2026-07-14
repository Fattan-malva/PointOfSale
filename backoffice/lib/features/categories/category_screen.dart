import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/backoffice_shimmer.dart';
import '../../models/category_model.dart';
import 'category_provider.dart';
import 'category_modal.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final AnimationController _animController;
  int _lastListHash = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(categoryProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryProvider);

    final listHash = Object.hashAll(state.categories.map((c) => c.id));
    if (listHash != _lastListHash && state.categories.isNotEmpty) {
      _lastListHash = listHash;
      _animController.reset();
      _animController.forward();
    }

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: RefreshIndicator(
        onRefresh: () => ref.read(categoryProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildHeader(state),
            const SizedBox(height: 24),
            _buildSearch(),
            const SizedBox(height: 20),
            _buildBody(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CategoryState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.04,
                height: 1.1,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${state.categories.length} categor${state.categories.length != 1 ? 'ies' : 'y'}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF787774),
                height: 1.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _onAddCategory(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEAEAEA)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 16, color: Color(0xFF111111)),
                SizedBox(width: 8),
                Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF111111)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search categories...',
                hintStyle:
                    TextStyle(fontSize: 14, color: AppColors.textDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
              onChanged: (v) =>
                  ref.read(categoryProvider.notifier).setSearch(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CategoryState state) {
    if (state.isLoading) {
      return Column(
        children: List.generate(
          10,
          (i) => const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: BackofficeShimmerRow(dense: true),
          ),
        ),
      );
    }

    if (state.categories.isEmpty) {
      return Center(
        child: Text(
          state.error ?? 'No categories found',
          style: const TextStyle(fontSize: 14, color: Color(0xFF787774)),
        ),
      );
    }

    return Column(
      children: List.generate(state.categories.length, (i) {
        final cat = state.categories[i];
        return _AnimatedEntry(
          controller: _animController,
          index: i,
          child: _buildCategoryCard(cat),
        );
      }),
    );
  }

  Widget _buildCategoryCard(CategoryModel cat) {
    final (pastelBg, pastelFg) = _pastelFor(cat.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: pastelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                cat.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: pastelFg,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cat.isActive
                              ? AppColors.pastelGreen
                              : AppColors.pastelRed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          cat.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.05,
                            color: cat.isActive
                                ? AppColors.pastelGreenText
                                : AppColors.pastelRedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (cat.description != null && cat.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        cat.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF787774),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.edit_rounded,
              onTap: () => _onEditCategory(cat),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.pastelRedText,
              onTap: () => _onDeleteCategory(cat),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color) _pastelFor(String name) {
    final hash = name.hashCode.abs();
    final palettes = [
      (AppColors.pastelBlue, AppColors.pastelBlueText),
      (AppColors.pastelRed, AppColors.pastelRedText),
      (AppColors.pastelGreen, AppColors.pastelGreenText),
      (AppColors.pastelYellow, AppColors.pastelYellowText),
    ];
    return palettes[hash % palettes.length];
  }

  Future<void> _onAddCategory() async {
    final result = await CategoryModal.create(context);
    if (result == null || !context.mounted) return;

    final success =
        await ref.read(categoryProvider.notifier).createCategory(result);
    if (!context.mounted) return;
    final err = ref.read(categoryProvider).error;
    _snack(
      success ? 'Category created' : (err ?? 'Failed to create category'),
      ok: success,
    );
  }

  Future<void> _onEditCategory(CategoryModel cat) async {
    final result = await CategoryModal.edit(context, cat);
    if (result == null || !context.mounted) return;

    final success = await ref
        .read(categoryProvider.notifier)
        .updateCategory(cat.id, result);
    if (!context.mounted) return;
    final err = ref.read(categoryProvider).error;
    _snack(
      success ? 'Category updated' : (err ?? 'Failed to update category'),
      ok: success,
    );
  }

  Future<void> _onDeleteCategory(CategoryModel cat) async {
    final confirmed = await CategoryModal.confirmDelete(context, cat.name);
    if (!confirmed || !context.mounted) return;

    final success =
        await ref.read(categoryProvider.notifier).deleteCategory(cat.id);
    if (!context.mounted) return;
    final err = ref.read(categoryProvider).error;
    _snack(
      success ? 'Category deleted' : (err ?? 'Failed to delete category'),
      ok: success,
    );
  }

  void _snack(String message, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ok ? AppColors.pastelGreenText : AppColors.pastelRedText,
          ),
        ),
        backgroundColor: ok ? AppColors.pastelGreen : AppColors.pastelRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFFEAEAEA)),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _AnimatedEntry({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double start = (index * 0.06).clamp(0.0, 0.6);
    final double end = (start + 0.2).clamp(0.0, 1.0);
    const curve = Cubic(0.16, 1.0, 0.3, 1.0);

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: curve),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: curve),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    this.iconColor = const Color(0xFF5C5C63),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEAEAEA)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}
