import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/core/network/api_exception.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/shared/models/domain_model.dart';

class DomainsRepository {
  final DioClient _dioClient;

  DomainsRepository(this._dioClient);

  Future<List<DomainModel>> fetchDomains() async {
    try {
      final response = await _dioClient.get('/domains');
      final List data = response.data['data'] ?? [];
      return data.map((json) => DomainModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch domains', e);
      throw Exception('Failed to load domains.');
    }
  }

  Future<DomainModel> createDomain(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.post('/domains', data: payload);
      return DomainModel.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Failed to create domain', e);
      if (e is ApiException) throw Exception(e.message);
      throw Exception('Failed to create domain.');
    }
  }

  Future<DomainModel> updateDomain(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.put('/domains/$id', data: payload);
      return DomainModel.fromJson(response.data['data']);
    } catch (e) {
      AppLogger.error('Failed to update domain', e);
      if (e is ApiException) throw Exception(e.message);
      throw Exception('Failed to update domain.');
    }
  }

  Future<void> deleteDomain(String id) async {
    try {
      await _dioClient.delete('/domains/$id');
    } catch (e) {
      AppLogger.error('Failed to delete domain', e);
      if (e is ApiException) throw Exception(e.message);
      throw Exception('Failed to delete domain.');
    }
  }
}

final domainsRepositoryProvider = Provider<DomainsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DomainsRepository(dioClient);
});
