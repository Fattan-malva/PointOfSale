import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import 'category_provider.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearch(),
            const SizedBox(height: 20),
            Expanded(child: _buildList(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            const Text(
              'Manage your product categories',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF787774),
                height: 1.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showAddDialog(),
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
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF787774)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search categories...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFA8A8AE),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111111),
              ),
              onChanged: (v) => ref.read(categoryProvider.notifier).setSearch(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(CategoryState state) {
    if (state.isLoading) {
      return const Center(
        child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
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

    return ListView.builder(
      itemCount: state.categories.length,
      itemBuilder: (_, i) {
        final cat = state.categories[i];
        return _AnimatedEntry(
          controller: _animController,
          index: i,
          child: _buildCategoryCard(cat),
        );
      },
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              onTap: () => _showEditDialog(cat),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.pastelRedText,
              onTap: () => _confirmDelete(cat.id, cat.name),
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

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final loading = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (ctx) => _DialogFrame(
        title: 'Add Category',
        children: [
          _DialogField(controller: nameCtrl, label: 'Category Name', hint: 'e.g. Food & Beverage'),
          const SizedBox(height: 16),
          _DialogField(controller: descCtrl, label: 'Description', hint: 'Optional description'),
        ],
        actions: (close) => [
          _CancelBtn(close: close),
          _ActionBtn(
            label: 'Save',
            loading: loading,
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              loading.value = true;
              final err = await ref.read(categoryProvider.notifier).createCategory({
                'CategoryName': nameCtrl.text.trim(),
                'Description': descCtrl.text.trim(),
              });
              loading.value = false;
              if (err == null) {
                close();
                _snack('Category created', ok: true);
              } else {
                _snack(err, ok: false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(dynamic cat) {
    final nameCtrl = TextEditingController(text: cat.name);
    final descCtrl = TextEditingController(text: cat.description ?? '');
    final loading = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (ctx) => _DialogFrame(
        title: 'Edit Category',
        children: [
          _DialogField(controller: nameCtrl, label: 'Category Name'),
          const SizedBox(height: 16),
          _DialogField(controller: descCtrl, label: 'Description'),
        ],
        actions: (close) => [
          _CancelBtn(close: close),
          _ActionBtn(
            label: 'Update',
            loading: loading,
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              loading.value = true;
              final err = await ref.read(categoryProvider.notifier).updateCategory(cat.id, {
                'CategoryName': nameCtrl.text.trim(),
                'Description': descCtrl.text.trim(),
              });
              loading.value = false;
              if (err == null) {
                close();
                _snack('Category updated', ok: true);
              } else {
                _snack(err, ok: false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    final loading = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (ctx) => _DialogFrame(
        title: 'Delete Category',
        children: [
          Text(
            'Are you sure you want to delete "$name"?',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5C5C63),
              height: 1.5,
            ),
          ),
        ],
        actions: (close) => [
          _CancelBtn(close: close),
          _ActionBtn(
            label: 'Delete',
            destructive: true,
            loading: loading,
            onPressed: () async {
              loading.value = true;
              final err = await ref.read(categoryProvider.notifier).deleteCategory(id);
              loading.value = false;
              if (err == null) {
                close();
                _snack('Category deleted', ok: true);
              } else {
                _snack(err, ok: false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _snack(String message, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ok ? AppColors.pastelGreenText : AppColors.pastelRedText,
        )),
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

  const _AnimatedEntry({required this.controller, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final double start = (index * 0.06).clamp(0.0, 0.6);
    final double end = (start + 0.2).clamp(0.0, 1.0);
    const curve = Cubic(0.16, 1.0, 0.3, 1.0);

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Interval(start, end, curve: curve)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: controller, curve: Interval(start, end, curve: curve)),
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

class _DialogFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget> Function(VoidCallback close) actions;

  const _DialogFrame({
    required this.title,
    required this.children,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFEAEAEA)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
          color: Color(0xFF111111),
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
      actions: [
        ...actions(() => Navigator.pop(context)),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;

  const _DialogField({required this.controller, required this.label, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.03,
            color: Color(0xFF787774),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA8A8AE),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
          ),
        ),
      ],
    );
  }
}

class _CancelBtn extends StatelessWidget {
  final VoidCallback close;
  const _CancelBtn({required this.close});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: close,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF787774),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: const Text('Cancel', style: TextStyle(fontSize: 14)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool destructive;
  final ValueNotifier<bool> loading;
  final VoidCallback onPressed;

  const _ActionBtn({
    required this.label,
    this.destructive = false,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loading,
      builder: (_, isLoading, __) => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: destructive ? const Color(0xFF9F2F2D) : const Color(0xFF111111),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFEAEAEA),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
