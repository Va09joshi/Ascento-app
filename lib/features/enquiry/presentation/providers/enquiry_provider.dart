import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/features/enquiry/data/models/enquiry_model.dart';
import 'package:ascento_abacus/features/enquiry/data/repositories/enquiry_repository.dart';

final enquiriesListProvider = FutureProvider.autoDispose<List<EnquiryModel>>((ref) async {
  final repository = ref.watch(enquiryRepositoryProvider);
  return await repository.getEnquiries();
});
