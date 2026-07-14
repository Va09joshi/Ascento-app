import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/features/meetings/data/repositories/meetings_repository.dart';

final meetingsClassFilterProvider = StateProvider<String?>((ref) => null);
final meetingsSectionFilterProvider = StateProvider<String?>((ref) => null);

final meetingsListProvider = FutureProvider.autoDispose<List<MeetingItem>>((ref) async {
  final classId = ref.watch(meetingsClassFilterProvider);
  final sectionId = ref.watch(meetingsSectionFilterProvider);
  return ref.watch(meetingsRepositoryProvider).getMeetings(classId: classId, sectionId: sectionId);
});
