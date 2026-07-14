import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_modal.dart';

class TableModal {
  static Future<Map<String, dynamic>?> create(
    BuildContext context, {
    required List<dynamic> branches,
  }) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    final loading = ValueNotifier(false);
    String? branchId;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _TableFormDialog(
          mode: _DialogMode.create,
          codeCtrl: codeCtrl,
          nameCtrl: nameCtrl,
          capacityCtrl: capacityCtrl,
          loading: loading,
          branches: branches,
          initialBranchId: branchId,
          onSave: () async {
            final code = codeCtrl.text.trim();
            final name = nameCtrl.text.trim();
            if (branchId == null || code.isEmpty) return;

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            final data = <String, dynamic>{
              'BranchID': branchId,
              'TableCode': code,
              'TableName': name,
            };
            if (capacityCtrl.text.isNotEmpty) {
              data['Capacity'] = int.tryParse(capacityCtrl.text);
            }

            Navigator.pop(context, data);
          },
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> edit(
    BuildContext context,
    dynamic table, {
    required List<dynamic> branches,
  }) {
    final codeCtrl = TextEditingController(text: table.tableCode);
    final nameCtrl = TextEditingController(text: table.tableName ?? '');
    final capacityCtrl =
        TextEditingController(text: table.capacity?.toString() ?? '');
    final loading = ValueNotifier(false);
    String? branchId = table.branchId?.toString();

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) {
        return _TableFormDialog(
          mode: _DialogMode.edit,
          codeCtrl: codeCtrl,
          nameCtrl: nameCtrl,
          capacityCtrl: capacityCtrl,
          loading: loading,
          branches: branches,
          initialBranchId: branchId,
          onSave: () async {
            final code = codeCtrl.text.trim();
            final name = nameCtrl.text.trim();
            if (branchId == null || code.isEmpty) return;

            loading.value = true;
            await Future.delayed(const Duration(milliseconds: 100));
            loading.value = false;

            final data = <String, dynamic>{
              'BranchID': branchId,
              'TableCode': code,
              'TableName': name,
            };
            if (capacityCtrl.text.isNotEmpty) {
              data['Capacity'] = int.tryParse(capacityCtrl.text);
            }

            Navigator.pop(context, data);
          },
        );
      },
    );
  }

  static Future<bool> confirmDelete(
    BuildContext context,
    String tableCode,
  ) {
    final loading = ValueNotifier(false);

    return AppModal.show<bool>(
      context,
      AppModalConfig(
        title: 'Delete Table',
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
              message: 'Are you sure you want to delete this table?'),
          const SizedBox(height: 6),
          Text(
            '“$tableCode”',
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

class _TableFormDialog extends StatefulWidget {
  final _DialogMode mode;
  final TextEditingController codeCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController capacityCtrl;
  final ValueNotifier<bool> loading;
  final List<dynamic> branches;
  final String? initialBranchId;
  final VoidCallback onSave;

  const _TableFormDialog({
    required this.mode,
    required this.codeCtrl,
    required this.nameCtrl,
    required this.capacityCtrl,
    required this.loading,
    required this.branches,
    required this.initialBranchId,
    required this.onSave,
  });

  @override
  State<_TableFormDialog> createState() => _TableFormDialogState();
}

class _TableFormDialogState extends State<_TableFormDialog> {
  late String? _branchId;

  @override
  void initState() {
    super.initState();
    _branchId = widget.initialBranchId;
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
                    ? 'Create Table'
                    : 'Edit Table',
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
                    ? 'Add a new table to your venue'
                    : 'Update table details',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF787774),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildBranchDropdown(),
              const SizedBox(height: 16),
              _buildField('Table Code', widget.codeCtrl),
              const SizedBox(height: 16),
              _buildField('Table Name', widget.nameCtrl, hint: 'Optional'),
              const SizedBox(height: 16),
              _buildField('Capacity', widget.capacityCtrl,
                  hint: 'Optional', keyboardType: TextInputType.number),
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

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BRANCH',
          style: TextStyle(
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _branchId,
              isExpanded: true,
              hint: const Text(
                'Select Branch',
                style: TextStyle(fontSize: 14, color: Color(0xFF787774)),
              ),
              items: widget.branches.map((b) {
                return DropdownMenuItem<String>(
                  value: b.id.toString(),
                  child: Text(
                    b.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111111),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  _branchId = v;
                });
              },
            ),
          ),
        ),
      ],
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

// Reuse ConfirmContent dari modifier_modal.dart atau buat file terpisah
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
