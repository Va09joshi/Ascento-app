import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/features/users/data/repositories/teachers_repository.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';

final teachersRepositoryProvider = Provider<TeachersRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TeachersRepository(dioClient);
});

final teachersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final repo = ref.watch(teachersRepositoryProvider);
  return repo.getTeachers();
});

final myStudentsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(teachersRepositoryProvider);
  return repo.getMyStudentsBySection();
});

class TeachersNotifier extends StateNotifier<AsyncValue<void>> {
  final TeachersRepository _repository;
  final Ref _ref;

  TeachersNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> createTeacher(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createTeacher(data);
      state = const AsyncValue.data(null);
      _ref.invalidate(teachersProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateTeacher(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateTeacher(id, data);
      state = const AsyncValue.data(null);
      _ref.invalidate(teachersProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deactivateTeacher(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deactivateTeacher(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(teachersProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final teachersNotifierProvider = StateNotifierProvider<TeachersNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(teachersRepositoryProvider);
  return TeachersNotifier(repo, ref);
});
