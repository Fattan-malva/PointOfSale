import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/backoffice_shimmer.dart';
import 'modifier_provider.dart';
import 'modifier_modal.dart';

// Import model - sesuaikan dengan lokasi model Anda
import '../../models/modifier_model.dart';

class ModifierScreen extends ConsumerStatefulWidget {
  const ModifierScreen({super.key});

  @override
  ConsumerState<ModifierScreen> createState() => _ModifierScreenState();
}

class _ModifierScreenState extends ConsumerState<ModifierScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final AnimationController _animController; // Sudah late
  int _lastListHash = 0;

  @override
  void initState() {
    super.initState();
    // Inisialisasi di sini
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(modifierProvider.notifier).refresh();
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
    final state = ref.watch(modifierProvider);

    final listHash = Object.hashAll(state.modifiers.map((i) => i.id));
    if (listHash != _lastListHash && state.modifiers.isNotEmpty) {
      _lastListHash = listHash;
      _animController.reset();
      _animController.forward();
    }

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: RefreshIndicator(
        onRefresh: () => ref.read(modifierProvider.notifier).refresh(),
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

  Widget _buildHeader(ModifierState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modifiers',
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
              '${state.modifiers.length} modifier${state.modifiers.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF787774),
                height: 1.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _onAddModifier(),
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
                  'Add Modifier',
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
                hintText: 'Search modifiers...',
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
                  ref.read(modifierProvider.notifier).setSearch(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ModifierState state) {
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

    if (state.modifiers.isEmpty) {
      return Center(
        child: Text(
          state.error ?? 'No modifiers found',
          style: const TextStyle(fontSize: 14, color: Color(0xFF787774)),
        ),
      );
    }

    return Column(
      children: List.generate(state.modifiers.length, (i) {
        final modifier = state.modifiers[i];
        return _AnimatedEntry(
          controller: _animController,
          index: i,
          child: _buildModifierCard(modifier, state),
        );
      }),
    );
  }

  Widget _buildModifierCard(ModifierModel modifier, ModifierState state) {
    final selected = state.selectedModifierId == modifier.id;

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
              child: Icon(
                modifier.isRequired ? Icons.lock_rounded : Icons.lock_open_rounded,
                size: 18,
                color: const Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: () => _onSelectModifier(modifier.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            modifier.name,
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
                            color: modifier.isRequired
                                ? AppColors.pastelBlue
                                : AppColors.pastelYellow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            modifier.isRequired ? 'Required' : 'Optional',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.05,
                              color: modifier.isRequired
                                  ? AppColors.pastelBlueText
                                  : AppColors.pastelYellowText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Max Select: ${modifier.maxSelect ?? 1} • '
                      '${state.currentOptions.length} option${state.currentOptions.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF787774),
                        height: 1.4,
                      ),
                    ),
                    if (selected && state.currentOptions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildOptionsPreview(state),
                      ),
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _onAddOption(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFEAEAEA)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded,
                                        size: 14, color: Color(0xFF111111)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add Option',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.edit_rounded,
              onTap: () => _onEditModifier(modifier),
            ),
            const SizedBox(width: 8),
            _IconAction(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.pastelRedText,
              onTap: () => _onDeleteModifier(modifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsPreview(ModifierState state) {
    final options = state.currentOptions.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Color(0xFF787774)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      opt.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF787774),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (opt.additionalPrice != null && opt.additionalPrice! > 0)
                    Text(
                      '+Rp ${_fmt(opt.additionalPrice!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF787774),
                      ),
                    ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: Icons.edit_rounded,
                    iconColor: const Color(0xFF787774),
                    onTap: () => _onEditOption(opt),
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: Icons.delete_outline_rounded,
                    iconColor: AppColors.pastelRedText,
                    onTap: () => _onDeleteOption(opt),
                  ),
                ],
              ),
            )),
        if (state.currentOptions.length > 3)
          Text(
            '+${state.currentOptions.length - 3} more options',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF787774),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  void _onSelectModifier(String modifierId) {
    ref.read(modifierProvider.notifier).selectModifier(modifierId);
  }

  Future<void> _onAddModifier() async {
    final result = await ModifierModal.create(context);
    if (result == null || !context.mounted) return;

    final ok = await ref.read(modifierProvider.notifier).createModifier(result);
    if (!context.mounted) return;
    final err = ref.read(modifierProvider).error;
    _snack(
      ok
          ? 'Modifier created'
          : (err != null ? 'Failed: $err' : 'Failed to create modifier'),
      ok: ok,
    );
  }

  Future<void> _onEditModifier(ModifierModel modifier) async {
    final result = await ModifierModal.edit(context, modifier);
    if (result == null || !context.mounted) return;

    final ok = await ref
        .read(modifierProvider.notifier)
        .updateModifier(modifier.id, result);
    if (!context.mounted) return;
    final err = ref.read(modifierProvider).error;
    _snack(
      ok
          ? 'Modifier updated'
          : (err != null ? 'Failed: $err' : 'Failed to update modifier'),
      ok: ok,
    );
  }

  Future<void> _onDeleteModifier(ModifierModel modifier) async {
    final confirmed = await ModifierModal.confirmDelete(context, modifier.name);
    if (!confirmed || !context.mounted) return;

    final ok =
        await ref.read(modifierProvider.notifier).deleteModifier(modifier.id);
    if (!context.mounted) return;
    final err = ref.read(modifierProvider).error;
    _snack(
      ok
          ? 'Modifier deleted'
          : (err != null ? 'Failed: $err' : 'Failed to delete modifier'),
      ok: ok,
    );
  }

  Future<void> _onAddOption() async {
    final selectedId = ref.read(modifierProvider).selectedModifierId;
    if (selectedId == null) return;

    final result = await ModifierOptionModal.create(context);
    if (result == null || !context.mounted) return;

    final ok = await ref
        .read(modifierProvider.notifier)
        .createOption(selectedId, result);
    if (!context.mounted) return;
    final err = ref.read(modifierProvider).error;
    _snack(
      ok
          ? 'Option added'
          : (err != null ? 'Failed: $err' : 'Failed to add option'),
      ok: ok,
    );
  }

  Future<void> _onEditOption(ModifierOptionModel option) async {
    final result = await ModifierOptionModal.edit(context, option);
    if (result == null || !context.mounted) return;

    final ok = await ref
        .read(modifierProvider.notifier)
        .updateOption(option.id, result);
    if (!context.mounted) return;
    final err = ref.read(modifierProvider).error;
    _snack(
      ok
          ? 'Option updated'
          : (err != null ? 'Failed: $err' : 'Failed to update option'),
      ok: ok,
    );
  }

  Future<void> _onDeleteOption(ModifierOptionModel option) async {
    final confirmed =
        await ModifierModal.confirmDeleteOption(context, option.name);
    if (!confirmed || !context.mounted) return;

    final ok =
        await ref.read(modifierProvider.notifier).deleteOption(option.id);
    if (!context.mounted) return;
    final err = ref.read(modifierProvider).error;
    _snack(
      ok
          ? 'Option deleted'
          : (err != null ? 'Failed: $err' : 'Failed to delete option'),
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
