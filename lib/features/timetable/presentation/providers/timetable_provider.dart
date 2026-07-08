import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/timetable/data/repositories/timetable_repository.dart';

// State providers for holding selected dropdown values
final selectedClassIdProvider = StateProvider<String?>((ref) => null);
final selectedSectionIdProvider = StateProvider<String?>((ref) => null);

// Fetch provider for section timetable
final sectionTimetableProvider = FutureProvider.autoDispose<List<TimetableSlot>>((ref) async {
  final sectionId = ref.watch(selectedSectionIdProvider);
  
  if (sectionId == null || sectionId.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(timetableRepositoryProvider);
  return await repository.getSectionTimetable(sectionId);
});
