import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';

class AdminDashboardStats {
  final int totalStudents;
  final int totalTeachers;
  final int totalBranches;
  final String revenueYTD;

  const AdminDashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalBranches,
    required this.revenueYTD,
  });

  factory AdminDashboardStats.empty() {
    return const AdminDashboardStats(
      totalStudents: 0,
      totalTeachers: 0,
      totalBranches: 0,
      revenueYTD: 'Rs 0',
    );
  }
}

class AdminRepository {
  final DioClient _dioClient;

  AdminRepository(this._dioClient);

  Future<AdminDashboardStats> fetchDashboardStats() async {
    try {
      // Execute API calls concurrently to minimize latency
      final responses = await Future.wait([
        _dioClient.get('/admin/users?role=student'),
        _dioClient.get('/admin/users?role=teacher'),
        _dioClient.get('/branches'),
      ]);

      // Parse the JSON array lengths to get actual backend metrics
      final studentData = responses[0].data['data'] as List?;
      final teacherData = responses[1].data['data'] as List?;
      final branchData = responses[2].data['data'] as List?;

      final totalStudents = studentData?.length ?? 0;
      final totalTeachers = teacherData?.length ?? 0;
      final totalBranches = branchData?.length ?? 0;

      // Backend lacks explicit accounting stats right now, so we placeholder revenue based on student count
      final revenue = 'Rs ${(totalStudents * 5000 / 1000000).toStringAsFixed(1)}M';

      return AdminDashboardStats(
        totalStudents: totalStudents,
        totalTeachers: totalTeachers,
        totalBranches: totalBranches,
        revenueYTD: revenue,
      );
    } catch (e) {
      AppLogger.error('Failed to fetch real admin dashboard stats', e);
      throw Exception('Failed to load dashboard statistics.');
    }
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AdminRepository(dioClient);
});
