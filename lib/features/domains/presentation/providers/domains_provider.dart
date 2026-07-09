import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/domain_model.dart';
import 'package:ascento_abacus/features/domains/data/repositories/domains_repository.dart';

class DomainsListNotifier extends StateNotifier<AsyncValue<List<DomainModel>>> {
  final DomainsRepository _repository;

  DomainsListNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchDomains();
  }

  Future<void> fetchDomains() async {
    state = const AsyncValue.loading();
    try {
      final domains = await _repository.fetchDomains();
      state = AsyncValue.data(domains);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createDomain(Map<String, dynamic> payload) async {
    try {
      final newDomain = await _repository.createDomain(payload);
      if (state is AsyncData) {
        state = AsyncValue.data([...state.value!, newDomain]);
      } else {
        await fetchDomains();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDomain(String id, Map<String, dynamic> payload) async {
    try {
      final updatedDomain = await _repository.updateDomain(id, payload);
      if (state is AsyncData) {
        final current = state.value!;
        final updatedList = current.map((domain) {
          return domain.id == id ? updatedDomain : domain;
        }).toList();
        state = AsyncValue.data(updatedList);
      } else {
        await fetchDomains();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDomain(String id) async {
    try {
      await _repository.deleteDomain(id);
      if (state is AsyncData) {
        final current = state.value!;
        state = AsyncValue.data(current.where((domain) => domain.id != id).toList());
      } else {
        await fetchDomains();
      }
    } catch (e) {
      rethrow;
    }
  }
}

final domainsListProvider = StateNotifierProvider<DomainsListNotifier, AsyncValue<List<DomainModel>>>((ref) {
  final repository = ref.watch(domainsRepositoryProvider);
  return DomainsListNotifier(repository);
});
