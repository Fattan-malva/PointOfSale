import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_modal.dart';
import '../../models/category_model.dart';

class CategoryModal {
  static Future<Map<String, dynamic>?> create(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final loading = ValueNotifier(false);

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _CategoryFormDialog(
          mode: _DialogMode.create,
          nameCtrl: nameCtrl,
          descCtrl: descCtrl,
          loading: loading,
          onSave: () async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            final data = <String, dynamic>{
              'CategoryName': name,
            };
            if (descCtrl.text.isNotEmpty) {
              data['Description'] = descCtrl.text.trim();
            }

            Navigator.pop(context, data);
          },
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> edit(
    BuildContext context,
    CategoryModel category,
  ) {
    final nameCtrl = TextEditingController(text: category.name);
    final descCtrl = TextEditingController(text: category.description ?? '');
    final loading = ValueNotifier(false);

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _CategoryFormDialog(
          mode: _DialogMode.edit,
          nameCtrl: nameCtrl,
          descCtrl: descCtrl,
          loading: loading,
          onSave: () async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            final data = <String, dynamic>{
              'CategoryName': name,
            };
            if (descCtrl.text.isNotEmpty) {
              data['Description'] = descCtrl.text.trim();
            }

            Navigator.pop(context, data);
          },
        );
      },
    );
  }

  static Future<bool> confirmDelete(
    BuildContext context,
    String categoryName,
  ) {
    final loading = ValueNotifier(false);

    return AppModal.show<bool>(
      context,
      AppModalConfig(
        title: 'Delete Category',
        subtitle: 'This action cannot be undone',
        loading: loading,
        destructive: true,
        submitLabel: 'Delete',
        onSubmit: () async {
          loading.value = true;
          await Future.delayed(const Duration(milliseconds: 100));
          loading.value = false;
          Navigator.pop(context, true);
        },
        fields: [
          ConfirmContent(
              message: 'Are you sure you want to delete this category?'),
          const SizedBox(height: 6),
          Text(
            '“$categoryName”',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111111),
              height: 1.6,
            ),
          ),
        ],
      ),
    ).then((v) => v ?? false);
  }
}

enum _DialogMode { create, edit }

class _CategoryFormDialog extends StatefulWidget {
  final _DialogMode mode;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final ValueNotifier<bool> loading;
  final VoidCallback onSave;

  const _CategoryFormDialog({
    required this.mode,
    required this.nameCtrl,
    required this.descCtrl,
    required this.loading,
    required this.onSave,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.mode == _DialogMode.create
                    ? 'Create Category'
                    : 'Edit Category',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03,
                  height: 1.2,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.mode == _DialogMode.create
                    ? 'Add a new product category'
                    : 'Update category details',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF787774),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildField('Category Name', widget.nameCtrl,
                  hint: 'e.g. Food & Beverage'),
              const SizedBox(height: 16),
              _buildField('Description', widget.descCtrl,
                  hint: 'Optional description', maxLines: 3),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF787774),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder(
                    valueListenable: widget.loading,
                    builder: (_, isLoading, __) {
                      return FilledButton(
                        onPressed: isLoading ? null : widget.onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFEAEAEA),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          minimumSize: const Size(80, 40),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                widget.mode == _DialogMode.create
                                    ? 'Create'
                                    : 'Update',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String hint = '',
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.06,
            color: Color(0xFF787774),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 14, color: AppColors.textDisabled),
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

// Reusable ConfirmContent
class ConfirmContent extends StatelessWidget {
  final String message;
  const ConfirmContent({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFE53935),
          size: 32,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111111),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
