import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_modal.dart';

class ModifierModal {
  static Future<Map<String, dynamic>?> create(BuildContext context) {
    final nameCtrl = TextEditingController();
    final maxSelectCtrl = TextEditingController();
    final loading = ValueNotifier(false);
    bool isRequired = false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _ModifierFormDialog(
          mode: _DialogMode.create,
          nameCtrl: nameCtrl,
          maxSelectCtrl: maxSelectCtrl,
          loading: loading,
          isRequired: isRequired,
          onSave: () async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            final data = <String, dynamic>{
              'ModifierName': name,
              'IsRequired': isRequired,
            };
            if (maxSelectCtrl.text.isNotEmpty) {
              data['MaxSelect'] = int.tryParse(maxSelectCtrl.text) ?? 1;
            }

            Navigator.pop(context, data);
          },
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> edit(
    BuildContext context,
    dynamic modifier,
  ) {
    final nameCtrl = TextEditingController(text: modifier.name);
    final maxSelectCtrl =
        TextEditingController(text: modifier.maxSelect?.toString() ?? '');
    final loading = ValueNotifier(false);
    bool isRequired = modifier.isRequired ?? false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _ModifierFormDialog(
          mode: _DialogMode.edit,
          nameCtrl: nameCtrl,
          maxSelectCtrl: maxSelectCtrl,
          loading: loading,
          isRequired: isRequired,
          onSave: () async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            final data = <String, dynamic>{
              'ModifierName': name,
              'IsRequired': isRequired,
            };
            if (maxSelectCtrl.text.isNotEmpty) {
              data['MaxSelect'] = int.tryParse(maxSelectCtrl.text) ?? 1;
            }

            Navigator.pop(context, data);
          },
        );
      },
    );
  }

  static Future<bool> confirmDelete(
    BuildContext context,
    String modifierName,
  ) {
    final loading = ValueNotifier(false);

    return AppModal.show<bool>(
      context,
      AppModalConfig(
        title: 'Delete Modifier',
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
              message: 'Are you sure you want to delete this modifier?'),
          const SizedBox(height: 6),
          Text(
            '“$modifierName”',
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

  static Future<bool> confirmDeleteOption(
    BuildContext context,
    String optionName,
  ) {
    final loading = ValueNotifier(false);

    return AppModal.show<bool>(
      context,
      AppModalConfig(
        title: 'Delete Option',
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
              message: 'Are you sure you want to delete this option?'),
          const SizedBox(height: 6),
          Text(
            '“$optionName”',
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

class _ModifierFormDialog extends StatefulWidget {
  final _DialogMode mode;
  final TextEditingController nameCtrl;
  final TextEditingController maxSelectCtrl;
  final ValueNotifier<bool> loading;
  final bool isRequired;
  final VoidCallback onSave;

  const _ModifierFormDialog({
    required this.mode,
    required this.nameCtrl,
    required this.maxSelectCtrl,
    required this.loading,
    required this.isRequired,
    required this.onSave,
  });

  @override
  State<_ModifierFormDialog> createState() => _ModifierFormDialogState();
}

class _ModifierFormDialogState extends State<_ModifierFormDialog> {
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    _isRequired = widget.isRequired;
  }

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
                    ? 'Create Modifier'
                    : 'Edit Modifier',
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
                    ? 'Add a new modifier group'
                    : 'Update modifier details',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF787774),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildField('Modifier Name', widget.nameCtrl),
              const SizedBox(height: 16),
              _buildField('Max Select', widget.maxSelectCtrl,
                  hint: '1', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildCheckbox(),
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
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
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

  Widget _buildCheckbox() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: CheckboxListTile(
        value: _isRequired,
        onChanged: (v) {
          setState(() {
            _isRequired = v ?? false;
          });
        },
        title: const Text(
          'Required',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111111),
          ),
        ),
        subtitle: const Text(
          'Customer must select at least one option',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF787774),
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
      ),
    );
  }
}

// Modifier Option Modal
class ModifierOptionModal {
  static Future<Map<String, dynamic>?> create(
    BuildContext context, {
    String? initialName,
    double? initialPrice,
  }) {
    final nameCtrl = TextEditingController(text: initialName ?? '');
    final priceCtrl =
        TextEditingController(text: initialPrice?.toString() ?? '');
    final loading = ValueNotifier(false);

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _OptionFormDialog(
          nameCtrl: nameCtrl,
          priceCtrl: priceCtrl,
          loading: loading,
          onSave: () async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            final data = <String, dynamic>{
              'OptionName': name,
            };
            if (priceCtrl.text.isNotEmpty) {
              data['AdditionalPrice'] = double.tryParse(priceCtrl.text) ?? 0;
            }

            Navigator.pop(context, data);
          },
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> edit(
    BuildContext context,
    dynamic option,
  ) {
    final nameCtrl = TextEditingController(text: option.name);
    final priceCtrl =
        TextEditingController(text: option.additionalPrice?.toString() ?? '');
    final loading = ValueNotifier(false);

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _OptionFormDialog(
          nameCtrl: nameCtrl,
          priceCtrl: priceCtrl,
          loading: loading,
          onSave: () async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            final data = <String, dynamic>{
              'OptionName': name,
            };
            if (priceCtrl.text.isNotEmpty) {
              data['AdditionalPrice'] = double.tryParse(priceCtrl.text) ?? 0;
            }

            Navigator.pop(context, data);
          },
        );
      },
    );
  }
}

class _OptionFormDialog extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final ValueNotifier<bool> loading;
  final VoidCallback onSave;

  const _OptionFormDialog({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.loading,
    required this.onSave,
  });

  @override
  State<_OptionFormDialog> createState() => _OptionFormDialogState();
}

class _OptionFormDialogState extends State<_OptionFormDialog> {
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
              const Text(
                'Add Option',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03,
                  height: 1.2,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add a new option to this modifier',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF787774),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildField('Option Name', widget.nameCtrl),
              const SizedBox(height: 16),
              _buildField('Additional Price', widget.priceCtrl,
                  hint: '0', keyboardType: TextInputType.number),
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
                            : const Text(
                                'Save',
                                style: TextStyle(
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
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
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
