import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/item_model.dart';
import 'package_provider.dart';
import 'package_modal.dart';
import '../items/repositories/item_repository.dart';
import '../../core/widgets/backoffice_shimmer.dart';

class PackageScreen extends ConsumerStatefulWidget {
  const PackageScreen({super.key});

  @override
  ConsumerState<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends ConsumerState<PackageScreen>
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
      ref.read(packageProvider.notifier).refresh();
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
    final state = ref.watch(packageProvider);

    final listHash = Object.hashAll(state.packages.map((i) => i.id));
    if (listHash != _lastListHash && state.packages.isNotEmpty) {
      _lastListHash = listHash;
      _animController.reset();
      _animController.forward();
    }

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: RefreshIndicator(
        onRefresh: () => ref.read(packageProvider.notifier).refresh(),
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

  Widget _buildHeader(PackageState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Packages',
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
              '${state.packages.length} package${state.packages.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF787774),
                height: 1.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _onAddPackage(),
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
                  'Add Package',
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
                hintText: 'Search packages...',
                hintStyle:
                    TextStyle(fontSize: 14, color: AppColors.textDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
              onChanged: (v) => ref.read(packageProvider.notifier).setSearch(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PackageState state) {
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

    if (state.packages.isEmpty) {
      return Center(
        child: Text(
          state.error ?? 'No packages found',
          style: const TextStyle(fontSize: 14, color: Color(0xFF787774)),
        ),
      );
    }

    return Column(
      children: List.generate(state.packages.length, (i) {
        final pkg = state.packages[i];
        return _AnimatedEntry(
          controller: _animController,
          index: i,
          child: _buildPackageCard(pkg, state),
        );
      }),
    );
  }

  Widget _buildPackageCard(ItemModel pkg, PackageState state) {
    final selected = state.selectedPackageId == pkg.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF7F6F3) : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xFF111111) : const Color(0xFFEAEAEA),
          width: selected ? 1.5 : 1,
        ),
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
                color: const Color(0xFFF0EDE8),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 20,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: () => _onSelectPackage(pkg.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            pkg.name,
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
                            color: pkg.isActive
                                ? AppColors.pastelGreen
                                : AppColors.pastelRed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            pkg.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.05,
                              color: pkg.isActive
                                  ? AppColors.pastelGreenText
                                  : AppColors.pastelRedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pkg.itemCode} • Rp ${_fmt(pkg.price)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF787774),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (state.selectedPackageId == pkg.id &&
                        state.packageDetails.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${state.packageDetails.length} item${state.packageDetails.length != 1 ? 's' : ''} in package',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF787774),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.edit_rounded,
              onTap: () => _onEditPackage(pkg),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.pastelRedText,
              onTap: () => _onDeletePackage(pkg),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelectPackage(String packageId) {
    ref.read(packageProvider.notifier).selectPackage(packageId);
  }

  Future<void> _onAddPackage() async {
    final state = ref.read(packageProvider);
    final items = state.availableItems.isNotEmpty
        ? state.availableItems
        : await ref.read(itemRepositoryProvider).getItems(itemType: 'Product');

    final result = await PackageModal.create(
      context,
      availableItems: items,
    );
    if (result == null || !context.mounted) return;

    final ok = await ref.read(packageProvider.notifier).createPackage({
      'ItemCode': result['ItemCode'],
      'ItemName': result['ItemName'],
      'Price': result['Price'],
    });

    if (!context.mounted) return;
    final err = ref.read(packageProvider).error;
    _snack(
      ok
          ? 'Package created'
          : (err != null ? 'Failed: $err' : 'Failed to create package'),
      ok: ok,
    );
  }

  Future<void> _onEditPackage(ItemModel pkg) async {
    final state = ref.read(packageProvider);
    final items = state.availableItems.isNotEmpty
        ? state.availableItems
        : await ref.read(itemRepositoryProvider).getItems(itemType: 'Product');

    final result = await PackageModal.edit(
      context,
      pkg,
      availableItems: items,
    );
    if (result == null || !context.mounted) return;

    final ok = await ref.read(packageProvider.notifier).updatePackage(pkg.id, {
      'ItemCode': result['ItemCode'],
      'ItemName': result['ItemName'],
      'Price': result['Price'],
    });

    if (!context.mounted) return;
    final err = ref.read(packageProvider).error;
    _snack(
      ok
          ? 'Package updated'
          : (err != null ? 'Failed: $err' : 'Failed to update package'),
      ok: ok,
    );
  }

  Future<void> _onDeletePackage(ItemModel pkg) async {
    final okConfirm = await PackageModal.confirmDelete(context, pkg.name);
    if (!context.mounted || !okConfirm) return;

    final ok = await ref.read(packageProvider.notifier).deletePackage(pkg.id);
    if (!context.mounted) return;
    final err = ref.read(packageProvider).error;
    _snack(
      ok
          ? 'Package deleted'
          : (err != null ? 'Failed: $err' : 'Failed to delete package'),
      ok: ok,
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

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
