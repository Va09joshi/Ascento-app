import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/branch_model.dart';
import 'package:ascento_abacus/features/branches/data/repositories/branches_repository.dart';

final branchesListProvider = FutureProvider.autoDispose<List<BranchModel>>((ref) async {
  final repository = ref.watch(branchesRepositoryProvider);
  return repository.getBranches();
});
