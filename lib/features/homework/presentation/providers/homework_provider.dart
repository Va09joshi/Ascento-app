import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/homework/data/repositories/homework_repository.dart';

final homeworkClassFilterProvider = StateProvider<String?>((ref) => null);
final homeworkSectionFilterProvider = StateProvider<String?>((ref) => null);

final homeworkListProvider = FutureProvider.autoDispose<List<HomeworkItem>>((ref) async {
  final classId = ref.watch(homeworkClassFilterProvider);
  final sectionId = ref.watch(homeworkSectionFilterProvider);
  return ref.watch(homeworkRepositoryProvider).getHomeworks(classId: classId, sectionId: sectionId);
});
