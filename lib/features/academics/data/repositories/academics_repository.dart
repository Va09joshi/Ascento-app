import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascento_abacus/shared/models/academic_year_model.dart';
import 'package:ascento_abacus/shared/models/class_model.dart';
import 'package:ascento_abacus/shared/models/section_model.dart';
import 'package:ascento_abacus/shared/models/subject_model.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/core/logging/app_logger.dart';
import 'package:ascento_abacus/core/network/dio_client.dart';

class AcademicsRepository {
  final DioClient _dioClient;

  AcademicsRepository(this._dioClient);

  // --- Academic Years ---
  Future<List<AcademicYearModel>> getAcademicYears() async {
    try {
      final response = await _dioClient.get('/academic-years');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => AcademicYearModel.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch academic years');
    } catch (e) {
      AppLogger.error('Failed to get academic years', e);
      rethrow;
    }
  }

  Future<AcademicYearModel> createAcademicYear(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/academic-years', data: data);
      if (response.data['success'] == true) {
        return AcademicYearModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create academic year');
    } catch (e) {
      AppLogger.error('Failed to create academic year', e);
      rethrow;
    }
  }

  Future<AcademicYearModel> updateAcademicYear(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.patch('/academic-years/$id', data: data);
      if (response.data['success'] == true) {
        return AcademicYearModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update academic year');
    } catch (e) {
      AppLogger.error('Failed to update academic year', e);
      rethrow;
    }
  }

  Future<void> deleteAcademicYear(String id) async {
    try {
      final response = await _dioClient.delete('/academic-years/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete academic year');
      }
    } catch (e) {
      AppLogger.error('Failed to delete academic year', e);
      rethrow;
    }
  }

  // --- Classes ---
  Future<List<ClassModel>> getClasses() async {
    try {
      final response = await _dioClient.get('/classes');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => ClassModel.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch classes');
    } catch (e) {
      AppLogger.error('Failed to get classes', e);
      rethrow;
    }
  }

  Future<ClassModel> createClass(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/classes', data: data);
      if (response.data['success'] == true) {
        return ClassModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create class');
    } catch (e) {
      AppLogger.error('Failed to create class', e);
      rethrow;
    }
  }

  Future<ClassModel> updateClass(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.patch('/classes/$id', data: data);
      if (response.data['success'] == true) {
        return ClassModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update class');
    } catch (e) {
      AppLogger.error('Failed to update class', e);
      rethrow;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      final response = await _dioClient.delete('/classes/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete class');
      }
    } catch (e) {
      AppLogger.error('Failed to delete class', e);
      rethrow;
    }
  }

  // --- Sections ---
  Future<List<SectionModel>> getSections() async {
    try {
      final response = await _dioClient.get('/sections');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => SectionModel.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch sections');
    } catch (e) {
      AppLogger.error('Failed to get sections', e);
      rethrow;
    }
  }

  Future<SectionModel> createSection(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/sections', data: data);
      if (response.data['success'] == true) {
        return SectionModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create section');
    } catch (e) {
      AppLogger.error('Failed to create section', e);
      rethrow;
    }
  }

  Future<SectionModel> updateSection(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.patch('/sections/$id', data: data);
      if (response.data['success'] == true) {
        return SectionModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update section');
    } catch (e) {
      AppLogger.error('Failed to update section', e);
      rethrow;
    }
  }

  Future<void> deleteSection(String id) async {
    try {
      final response = await _dioClient.delete('/sections/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete section');
      }
    } catch (e) {
      AppLogger.error('Failed to delete section', e);
      rethrow;
    }
  }

  Future<List<UserModel>> getSectionStudents(String id) async {
    try {
      final response = await _dioClient.get('/sections/$id/students');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => UserModel.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch section students');
    } catch (e) {
      AppLogger.error('Failed to get section students', e);
      rethrow;
    }
  }

  // --- Subjects ---
  Future<List<SubjectModel>> getSubjects() async {
    try {
      final response = await _dioClient.get('/subjects');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => SubjectModel.fromJson(json))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch subjects');
    } catch (e) {
      AppLogger.error('Failed to get subjects', e);
      rethrow;
    }
  }

  Future<SubjectModel> createSubject(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/subjects', data: data);
      if (response.data['success'] == true) {
        return SubjectModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create subject');
    } catch (e) {
      AppLogger.error('Failed to create subject', e);
      rethrow;
    }
  }

  Future<SubjectModel> updateSubject(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.patch('/subjects/$id', data: data);
      if (response.data['success'] == true) {
        return SubjectModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update subject');
    } catch (e) {
      AppLogger.error('Failed to update subject', e);
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      final response = await _dioClient.delete('/subjects/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete subject');
      }
    } catch (e) {
      AppLogger.error('Failed to delete subject', e);
      rethrow;
    }
  }
}

final academicsRepositoryProvider = Provider<AcademicsRepository>((ref) {
  return AcademicsRepository(ref.watch(dioClientProvider));
});
