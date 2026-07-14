import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/content/data/repositories/content_repository.dart';

final contentClassFilterProvider = StateProvider<String?>((ref) => null);

final contentListProvider = FutureProvider.autoDispose<List<ContentItem>>((ref) async {
  final classId = ref.watch(contentClassFilterProvider);
  return ref.watch(contentRepositoryProvider).getContent(classId: classId);
});
