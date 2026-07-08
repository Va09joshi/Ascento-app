import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/shared/models/branch_model.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

class BranchesRepository {
  final DioClient _dioClient;

  BranchesRepository(this._dioClient);

  Future<List<BranchModel>> getBranches() async {
    try {
      final response = await _dioClient.get('/branches');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => BranchModel.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch branches');
    } catch (e) {
      AppLogger.error('Failed to get branches', e);
      rethrow;
    }
  }

  Future<BranchModel> createBranch(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/branches', data: data);
      if (response.data['success'] == true) {
        return BranchModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create branch');
    } catch (e) {
      AppLogger.error('Failed to create branch', e);
      rethrow;
    }
  }

  Future<BranchModel> updateBranch(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.patch('/branches/$id', data: data);
      if (response.data['success'] == true) {
        return BranchModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update branch');
    } catch (e) {
      AppLogger.error('Failed to update branch', e);
      rethrow;
    }
  }

  Future<void> deleteBranch(String id) async {
    try {
      final response = await _dioClient.delete('/branches/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete branch');
      }
    } catch (e) {
      AppLogger.error('Failed to delete branch', e);
      rethrow;
    }
  }
}

final branchesRepositoryProvider = Provider<BranchesRepository>((ref) {
  return BranchesRepository(ref.watch(dioClientProvider));
});
