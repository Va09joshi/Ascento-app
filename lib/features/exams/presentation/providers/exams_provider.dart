import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/exams/data/repositories/exams_repository.dart';

final examsListProvider = FutureProvider.autoDispose<List<ExamSchedule>>((ref) async {
  final repository = ref.watch(examsRepositoryProvider);
  return await repository.getExams();
});
