import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(packageProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageProvider);

    final h = MediaQuery.of(context).size.height;
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
            SizedBox(
              height: h - 32 - 24 - 20 - 120,
              child: _buildBody(state),
            ),
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Packages',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.04,
                height: 1.1,
                color: Color(0xFF111111),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Manage your packages',
              style: TextStyle(
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
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: BackofficeShimmerRow(dense: true),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: state.selectedPackageId == null
                ? const Center(child: SizedBox.shrink())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      6,
                      (i) => const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: BackofficeShimmer(
                            width: double.infinity, height: 48),
                      ),
                    ),
                  ),
          ),
        ],
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildPackageList(state),
        ),
        if (state.selectedPackageId != null) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: _buildSelectedPackageItems(state),
          ),
        ],
      ],
    );
  }

  Widget _buildPackageList(PackageState state) {
    return ListView.builder(
      itemCount: state.packages.length,
      itemBuilder: (_, i) {
        final pkg = state.packages[i];
        final selected = state.selectedPackageId == pkg.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color:
                  selected ? const Color(0xFF111111) : const Color(0xFFEAEAEA),
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
                    color: const Color(0xFFF7F6F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.inventory_2_rounded,
                      size: 18, color: Color(0xFF111111)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    ],
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
      },
    );
  }

  Widget _buildSelectedPackageItems(PackageState state) {
    final packageId = state.selectedPackageId!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItemsHeader(onAdd: () => _onAddDetail(packageId, state)),
        const SizedBox(height: 16),
        Expanded(
          child: state.isLoadingDetails
              ? ListView.builder(
                  itemCount: 6,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: BackofficeShimmerRow(),
                  ),
                )
              : state.packageDetails.isEmpty
                  ? const Center(
                      child: Text(
                        'No items in this package',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF787774),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.packageDetails.length,
                      itemBuilder: (_, i) {
                        final detail = state.packageDetails[i];
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.itemName ?? detail.itemId,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111111),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Qty: ${detail.qty}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF787774),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _IconAction(
                                  icon: Icons.remove_circle_outline_rounded,
                                  iconColor: AppColors.pastelRedText,
                                  onTap: () async {
                                    final ok =
                                        await PackageModal.confirmRemoveDetail(
                                      context,
                                      detail.itemName ?? detail.itemId,
                                    );
                                    if (!context.mounted || !ok) return;
                                    await ref
                                        .read(packageProvider.notifier)
                                        .removeDetail(packageId, detail.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildItemsHeader({required VoidCallback onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Package Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
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
                  'Add Item',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onAddPackage() async {
    final result = await PackageModal.create(context);
    if (result == null || !context.mounted) return;

    final ok = await ref.read(packageProvider.notifier).createPackage({
      'ItemCode': result['ItemCode'],
      'ItemName': result['ItemName'],
      'Price': result['Price'],
    });

    if (!context.mounted) return;
    _snack(ok ? 'Package created' : 'Failed to create package', ok: ok);
  }

  Future<void> _onEditPackage(ItemModel pkg) async {
    final result = await PackageModal.edit(context, pkg);
    if (result == null || !context.mounted) return;

    final ok = await ref.read(packageProvider.notifier).updatePackage(pkg.id, {
      'ItemCode': result['ItemCode'],
      'ItemName': result['ItemName'],
      'Price': result['Price'],
    });

    if (!context.mounted) return;
    _snack(ok ? 'Package updated' : 'Failed to update package', ok: ok);
  }

  Future<void> _onDeletePackage(ItemModel pkg) async {
    final okConfirm = await PackageModal.confirmDelete(context, pkg.name);
    if (!context.mounted || !okConfirm) return;

    final ok = await ref.read(packageProvider.notifier).deletePackage(pkg.id);
    if (!context.mounted) return;
    _snack(ok ? 'Package deleted' : 'Failed to delete package', ok: ok);
  }

  Future<void> _onAddDetail(String packageId, PackageState state) async {
    final items = state.availableItems.isNotEmpty
        ? state.availableItems
        : await ref.read(itemRepositoryProvider).getItems(itemType: 'Product');

    final result = await PackageModal.addDetail(
      context,
      items: items,
      initialQty: 1,
    );

    if (result == null || !context.mounted) return;

    final itemId = result['ItemID'] as String;
    final qty = result['Qty'] as int;

    final ok = await ref
        .read(packageProvider.notifier)
        .addDetail(packageId, itemId, qty);

    if (!context.mounted) return;
    _snack(ok ? 'Item added to package' : 'Failed to add item', ok: ok);
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
