import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/core/constants/api_endpoints.dart';

class BranchRepository {
  final DioClient apiClient;

  BranchRepository(this.apiClient);

  // READ (List all branches)
  Future<List<dynamic>> getBranches() async {
    final response = await apiClient.get(ApiEndpoints.branches);
    return response.data['data'];
  }

  // CREATE
  Future<void> createBranch({required String name, required String city, required String address, required String phone}) async {
    await apiClient.post(ApiEndpoints.branches, data: {
      'name': name,
      'city': city,
      'address': address,
      'phone': phone,
    });
  }

  // UPDATE
  Future<void> updateBranch(String id, Map<String, dynamic> data) async {
    // We assume there's a PATCH method on dioClient or use standard _dio
    await apiClient.dio.patch('${ApiEndpoints.branches}/$id', data: data);
  }

  // DELETE (Soft Delete)
  Future<void> deleteBranch(String id) async {
    await apiClient.dio.delete('${ApiEndpoints.branches}/$id');
  }
}

// Provider
final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BranchRepository(dioClient);
});
