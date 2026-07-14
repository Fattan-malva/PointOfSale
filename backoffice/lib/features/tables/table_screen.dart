import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/backoffice_shimmer.dart';
import 'table_provider.dart';
import 'table_modal.dart';

class TableScreen extends ConsumerStatefulWidget {
  const TableScreen({super.key});

  @override
  ConsumerState<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends ConsumerState<TableScreen>
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
      ref.read(tableProvider.notifier).refresh();
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
    final state = ref.watch(tableProvider);

    final listHash = Object.hashAll(state.tables.map((i) => i.id));
    if (listHash != _lastListHash && state.tables.isNotEmpty) {
      _lastListHash = listHash;
      _animController.reset();
      _animController.forward();
    }

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: RefreshIndicator(
        onRefresh: () => ref.read(tableProvider.notifier).refresh(),
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

  Widget _buildHeader(TableState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tables',
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
              '${state.tables.length} table${state.tables.length != 1 ? 's' : ''}',
              style: const TextStyle(
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
                  'Add Table',
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
                hintText: 'Search tables...',
                hintStyle:
                    TextStyle(fontSize: 14, color: AppColors.textDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
              onChanged: (v) => ref.read(tableProvider.notifier).setSearch(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TableState state) {
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

    if (state.tables.isEmpty) {
      return Center(
        child: Text(
          state.error ?? 'No tables found',
          style: const TextStyle(fontSize: 14, color: Color(0xFF787774)),
        ),
      );
    }

    return Column(
      children: List.generate(state.tables.length, (i) {
        final table = state.tables[i];
        return _AnimatedEntry(
          controller: _animController,
          index: i,
          child: _buildTableCard(table),
        );
      }),
    );
  }

  Widget _buildTableCard(dynamic table) {
    final (pastelBg, pastelFg) = _pastelFor(table.tableCode);

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
                table.tableCode.substring(0, 1).toUpperCase(),
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
                          table.tableName ?? table.tableCode,
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
                          color: table.isActive
                              ? AppColors.pastelGreen
                              : AppColors.pastelRed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          table.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.05,
                            color: table.isActive
                                ? AppColors.pastelGreenText
                                : AppColors.pastelRedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildSubtitle(table),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF787774),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (table.capacity != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warmBone,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${table.capacity} seats',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF787774),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.edit_rounded,
              onTap: () => _showEditDialog(table),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.pastelRedText,
              onTap: () => _confirmDelete(table.id, table.tableCode),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(dynamic table) {
    final parts = <String>[table.tableCode];
    if (table.branchName != null && table.branchName!.isNotEmpty) {
      parts.add(table.branchName!);
    }
    return parts.join(' • ');
  }

  (Color, Color) _pastelFor(String code) {
    final hash = code.hashCode.abs();
    final palettes = [
      (AppColors.pastelBlue, AppColors.pastelBlueText),
      (AppColors.pastelRed, AppColors.pastelRedText),
      (AppColors.pastelGreen, AppColors.pastelGreenText),
      (AppColors.pastelYellow, AppColors.pastelYellowText),
    ];
    return palettes[hash % palettes.length];
  }

  Future<void> _showAddDialog() async {
    final state = ref.read(tableProvider);
    final result = await TableModal.create(
      context,
      branches: state.branches,
    );
    if (result == null || !context.mounted) return;

    final ok = await ref.read(tableProvider.notifier).createTable(result);
    if (!context.mounted) return;
    final err = ref.read(tableProvider).error;
    _snack(
      ok
          ? 'Table created'
          : (err != null ? 'Failed: $err' : 'Failed to create table'),
      ok: ok,
    );
  }

  Future<void> _showEditDialog(dynamic table) async {
    final state = ref.read(tableProvider);
    final result = await TableModal.edit(
      context,
      table,
      branches: state.branches,
    );
    if (result == null || !context.mounted) return;

    final ok =
        await ref.read(tableProvider.notifier).updateTable(table.id, result);
    if (!context.mounted) return;
    final err = ref.read(tableProvider).error;
    _snack(
      ok
          ? 'Table updated'
          : (err != null ? 'Failed: $err' : 'Failed to update table'),
      ok: ok,
    );
  }

  Future<void> _confirmDelete(String id, String code) async {
    final confirmed = await TableModal.confirmDelete(context, code);
    if (!confirmed || !context.mounted) return;

    final ok = await ref.read(tableProvider.notifier).deleteTable(id);
    if (!context.mounted) return;
    final err = ref.read(tableProvider).error;
    _snack(
      ok
          ? 'Table deleted'
          : (err != null ? 'Failed: $err' : 'Failed to delete table'),
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
