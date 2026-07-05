import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/network/network_info.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';

class SplashService {
  final NetworkInfo _networkInfo;

  const SplashService(this._networkInfo);

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
    
    // We simulate secure storage extraction via our StorageService. 
    // In production, you would swap this for the flutter_secure_storage package.
    // For now, we mock an existing login if needed, or return null if starting fresh.
    return 'ascento_abacus_secured_session_token_jwt';
  }

  // 4. Role checking: Extract user role metadata
  Future<UserRole> getUserRole() async {
    AppLogger.info('Resolving system access authorization rights...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Default mock is student. You can alter this to match teacher/admin accounts.
    return UserRole.student;
  }
}

// Global Splash Service Provider
final splashServiceProvider = Provider<SplashService>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return SplashService(networkInfo);
});
