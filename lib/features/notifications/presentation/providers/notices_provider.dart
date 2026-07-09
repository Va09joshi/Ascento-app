import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/notice_model.dart';
import 'package:ascento_abacus/features/notifications/data/repositories/notices_repository.dart';

class NoticesNotifier extends AutoDisposeAsyncNotifier<List<NoticeModel>> {
  @override
  Future<List<NoticeModel>> build() async {
    return ref.watch(noticesRepositoryProvider).getNotices();
  }

  Future<void> createNotice(dynamic data) async {
    final repository = ref.read(noticesRepositoryProvider);
    final newNotice = await repository.createNotice(data);
    if (state.hasValue) {
      state = AsyncValue.data([newNotice, ...state.value!]);
    } else {
      ref.invalidateSelf();
    }
  }

  Future<void> updateNotice(String id, dynamic data) async {
    final repository = ref.read(noticesRepositoryProvider);
    final updatedNotice = await repository.updateNotice(id, data);
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.map((n) => n.id == id ? updatedNotice : n).toList(),
      );
    } else {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteNotice(String id) async {
    final repository = ref.read(noticesRepositoryProvider);
    await repository.deleteNotice(id);
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((n) => n.id != id).toList(),
      );
    } else {
      ref.invalidateSelf();
    }
  }
}

final noticesListProvider = AsyncNotifierProvider.autoDispose<NoticesNotifier, List<NoticeModel>>(() {
  return NoticesNotifier();
});
