import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import 'employee_provider.dart';

class EmployeeScreen extends ConsumerStatefulWidget {
  const EmployeeScreen({super.key});

  @override
  ConsumerState<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends ConsumerState<EmployeeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Employees', style: AppTypography.h2),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.accent),
                  onPressed: () => _showAddEmployeeDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space6),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (value) {
                ref.read(employeeProvider.notifier).setSearch(value);
              },
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.employees.isEmpty
                      ? Center(
                          child: Text(state.error ?? 'No employees found', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                        )
                      : ListView.builder(
                          itemCount: state.employees.length,
                          itemBuilder: (_, i) {
                            final emp = state.employees[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.accentSoft,
                                  child: Text(emp.fullName.substring(0, 1), style: const TextStyle(color: AppColors.accent)),
                                ),
                                title: Text(emp.fullName),
                                subtitle: Text('${emp.roleName ?? 'No role'} • ${emp.branchName ?? ''}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: emp.isActive ? AppColors.success.withAlpha(25) : AppColors.error.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        emp.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(color: emp.isActive ? AppColors.success : AppColors.error, fontSize: 12),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.toggle_on,
                                        color: emp.isActive ? AppColors.success : AppColors.textSecondary,
                                        size: 24,
                                      ),
                                      onPressed: () => ref.read(employeeProvider.notifier).toggleActive(emp.id, !emp.isActive),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                                      onPressed: () => _showEditEmployeeDialog(context, emp),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String? roleId;
    String? branchId;
    final state = ref.read(employeeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameCtrl, label: 'Full Name'),
            const SizedBox(height: 12),
            AppTextField(controller: usernameCtrl, label: 'Username'),
            const SizedBox(height: 12),
            AppTextField(controller: passwordCtrl, label: 'Password', obscureText: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              items: state.roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
              onChanged: (v) => roleId = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
              items: state.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              onChanged: (v) => branchId = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;
              final data = <String, dynamic>{
                'FullName': nameCtrl.text,
                'Username': usernameCtrl.text,
                'Password': passwordCtrl.text,
              };
              if (roleId != null) data['RoleID'] = roleId;
              if (branchId != null) data['BranchID'] = branchId;
              await ref.read(employeeProvider.notifier).createEmployee(data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, dynamic emp) {
    final nameCtrl = TextEditingController(text: emp.fullName);
    final usernameCtrl = TextEditingController(text: emp.username);
    final state = ref.read(employeeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameCtrl, label: 'Full Name'),
            const SizedBox(height: 12),
            AppTextField(controller: usernameCtrl, label: 'Username'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: emp.roleId,
              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              items: state.roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || usernameCtrl.text.isEmpty) return;
              final data = <String, dynamic>{
                'FullName': nameCtrl.text,
                'Username': usernameCtrl.text,
              };
              await ref.read(employeeProvider.notifier).updateEmployee(emp.id, data);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
