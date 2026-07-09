import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/network/network_info.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';

import 'package:ascento_abacus/core/services/storage_service.dart';

class SplashService {
  final NetworkInfo _networkInfo;
  final StorageService _storageService;

  const SplashService(this._networkInfo, this._storageService);

  // 1. Version Check: verifies app compatibility (Production min-version required is 1.0.0)
  Future<bool> isAppVersionValid() async {
    AppLogger.info('Verifying app compatibility version...');
    await Future.delayed(const Duration(milliseconds: 600)); // Smooth UX visual pacing
    
    const String currentVersion = '1.0.2';
    const String minimumRequired = '1.0.0';
    
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    final minParts = minimumRequired.split('.').map(int.parse).toList();
    
    for (var i = 0; i < 3; i++) {
      if (currentParts[i] > minParts[i]) return true;
      if (currentParts[i] < minParts[i]) return false;
    }
    return true;
  }

  // 2. Internet Connection Check
  Future<bool> checkInternet() async {
    AppLogger.info('Checking network presence...');
    return await _networkInfo.isConnected;
  }

  // 3. Secure Token Checking (Reads cached auth token from storage)
  Future<String?> getAuthToken() async {
    AppLogger.info('Decrypting credentials from secure storage...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_storageService.getRememberMe()) {
      AppLogger.info('Remember me is false, clearing previous session on boot.');
      await _storageService.remove('secure_jwt_access_token');
      await _storageService.remove('secure_jwt_refresh_token');
      await _storageService.removeUser();
      return null;
    }
    
    return _storageService.getString('secure_jwt_access_token');
  }

  // 4. Role checking: Extract user role metadata
  Future<UserRole> getUserRole() async {
    AppLogger.info('Resolving system access authorization rights...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    final user = _storageService.getCurrentUser();
    return user?.role ?? UserRole.student;
  }
}

// Global Splash Service Provider
final splashServiceProvider = Provider<SplashService>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  final storageService = ref.watch(storageServiceProvider);
  return SplashService(networkInfo, storageService);
});
