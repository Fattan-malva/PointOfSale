import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../report_provider.dart';

class CategoryAnalysisScreen extends ConsumerWidget {
  const CategoryAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topItemsAsync = ref.watch(topItemsProvider({'branchId': null, 'dateFrom': null, 'dateTo': null}));

    return Scaffold(
      appBar: AppBar(title: const Text('Category Analysis')),
      body: topItemsAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sales by Category', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.space4),
              Expanded(
                child: ListView(
                  children: data
                      .fold<Map<String, double>>({}, (map, item) {
                        final cat = item['CategoryName'] as String? ?? 'Uncategorized';
                        map[cat] = (map[cat] ?? 0) + ((item['total'] as num?)?.toDouble() ?? 0);
                        return map;
                      })
                      .entries
                      .map((e) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.accentSoft,
                                child: Icon(Icons.category, color: AppColors.accent, size: 20),
                              ),
                              title: Text(e.key),
                              trailing: Text('Rp ${_fmt(e.value)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _fmt(double a) => a.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
