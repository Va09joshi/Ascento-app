import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/features/dashboard/data/repositories/admin_repository.dart';

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboardStats>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.fetchDashboardStats();
});
