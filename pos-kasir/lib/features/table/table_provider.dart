import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/table_model.dart';
import 'repositories/table_repository.dart';

final tableRepositoryProvider = Provider<TableRepository>((ref) {
  return TableRepository();
});

final tablesProvider = FutureProvider<List<TableModel>>((ref) async {
  final repo = ref.watch(tableRepositoryProvider);
  return repo.getTables();
});

final selectedTableProvider = StateProvider<TableModel?>((ref) => null);
