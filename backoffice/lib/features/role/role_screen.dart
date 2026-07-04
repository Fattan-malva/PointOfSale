import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import 'role_provider.dart';

class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});

  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(roleProvider.notifier).loadRoles());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roleProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Roles & Permissions', style: AppTypography.h2),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.accent),
                  onPressed: () => _showAddRoleDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space6),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListView(
                            children: state.roles.map((role) => Card(
                              color: state.selectedRoleId == role.id ? AppColors.accentSoft : null,
                              child: ListTile(
                                title: Text(role.name),
                                subtitle: role.description != null ? Text(role.description!) : null,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => ref.read(roleProvider.notifier).selectRole(role.id),
                              ),
                            )).toList(),
                          ),
                        ),
                        if (state.selectedRoleId != null) ...[
                          const SizedBox(width: AppSpacing.space4),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Permissions', style: AppTypography.h3),
                                const SizedBox(height: AppSpacing.space3),
                                Expanded(
                                  child: ListView(
                                    children: state.permissions
                                        .where((p) => p.module != null)
                                        .toList()
                                        .fold<Map<String, List<dynamic>>>(
                                          {},
                                          (map, p) {
                                            map.putIfAbsent(p.module!, () => []);
                                            map[p.module]!.add(p);
                                            return map;
                                          },
                                        )
                                        .entries
                                        .map((entry) => Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(entry.key, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent)),
                                                ...entry.value.map((p) => CheckboxListTile(
                                                  dense: true,
                                                  title: Text(p.name),
                                                  value: p.isAssigned,
                                                  onChanged: (_) {
                                                    final ids = state.permissions
                                                        .where((x) => x.isAssigned || x.id == p.id)
                                                        .map((x) => x.id)
                                                        .toList();
                                                    if (p.isAssigned) {
                                                      ids.remove(p.id);
                                                    } else {
                                                      ids.add(p.id);
                                                    }
                                                    ref.read(roleProvider.notifier).assignPermissions(state.selectedRoleId!, ids);
                                                  },
                                                )),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameCtrl, label: 'Role Name'),
            const SizedBox(height: 12),
            AppTextField(controller: descCtrl, label: 'Description'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              await ref.read(roleProvider.notifier).createRole({
                'RoleName': nameCtrl.text,
                'Description': descCtrl.text,
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
