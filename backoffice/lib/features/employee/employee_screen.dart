import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                // TODO: search
              },
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (_, i) {
                  final roles = ['Admin', 'Manager', 'Cashier', 'Kitchen', 'Cashier'];
                  final names = ['Super Admin', 'Branch Manager', 'Kasir 1', 'Staff Dapur', 'Kasir 2'];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accentSoft,
                        child: Text(names[i].substring(0, 1), style: const TextStyle(color: AppColors.accent)),
                      ),
                      title: Text(names[i]),
                      subtitle: Text(roles[i]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Active', style: TextStyle(color: AppColors.success, fontSize: 12)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
                            onPressed: () {},
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              items: ['Admin', 'Manager', 'Cashier', 'Kitchen'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Save')),
        ],
      ),
    );
  }
}
