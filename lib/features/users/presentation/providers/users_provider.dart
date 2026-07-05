import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/features/users/data/repositories/users_repository.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';

// Family provider to fetch users based on the role requested (e.g. 'admin', 'teacher')
final usersListProvider = FutureProvider.autoDispose.family<List<UserModel>, String>((ref, role) async {
  final repository = ref.watch(usersRepositoryProvider);
  return await repository.fetchUsers(role);
});
