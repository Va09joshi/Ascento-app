import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/academic_year_model.dart';
import 'package:ascento_abacus/shared/models/class_model.dart';
import 'package:ascento_abacus/shared/models/section_model.dart';
import 'package:ascento_abacus/shared/models/subject_model.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/features/academics/data/repositories/academics_repository.dart';

final academicYearsListProvider = FutureProvider.autoDispose<List<AcademicYearModel>>((ref) async {
  final repository = ref.watch(academicsRepositoryProvider);
  return repository.getAcademicYears();
});

final classesListProvider = FutureProvider.autoDispose<List<ClassModel>>((ref) async {
  final repository = ref.watch(academicsRepositoryProvider);
  return repository.getClasses();
});

final sectionsListProvider = FutureProvider.autoDispose<List<SectionModel>>((ref) async {
  final repository = ref.watch(academicsRepositoryProvider);
  return repository.getSections();
});

final subjectsListProvider = FutureProvider.autoDispose<List<SubjectModel>>((ref) async {
  final repository = ref.watch(academicsRepositoryProvider);
  return repository.getSubjects();
});

final sectionStudentsProvider = FutureProvider.autoDispose.family<List<UserModel>, String>((ref, sectionId) async {
  final repository = ref.watch(academicsRepositoryProvider);
  return repository.getSectionStudents(sectionId);
});
