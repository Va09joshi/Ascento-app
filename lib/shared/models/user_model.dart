enum UserRole {
  student,
  parent,
  teacher,
  admin,
  accountant, superAdmin,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final int starsCount;
  final int completedLevels;
  final String? phone;
  final String? gender;
  final String? status;
  final String? address;
  final String? domainId;
  final String? tempPassword;
  final bool mustChangePassword;
  final String? rollNumber;
  final String? className;
  final String? sectionName;
  final String? classId;
  final String? sectionId;
  final String? academicYearId;
  final String? city;
  final String? state;
  final String? country;
  final String? qualification;
  final int? experience;
  final DateTime? dateOfBirth;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.starsCount = 0,
    this.completedLevels = 0,
    this.phone,
    this.gender,
    this.status,
    this.address,
    this.domainId,
    this.tempPassword,
    this.mustChangePassword = false,
    this.rollNumber,
    this.className,
    this.sectionName,
    this.classId,
    this.sectionId,
    this.academicYearId,
    this.city,
    this.state,
    this.country,
    this.qualification,
    this.experience,
    this.dateOfBirth,
  });

  // Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'starsCount': starsCount,
      'completedLevels': completedLevels,
      'phone': phone,
      'gender': gender,
      'status': status,
      'address': address,
      'domainId': domainId,
      'tempPassword': tempPassword,
      'must_change_password': mustChangePassword,
      'city': city,
      'state': state,
      'country': country,
      'qualification': qualification,
      'experience': experience,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
    };
  }

  // Parse from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? rNumber;
    String? cName;
    String? sName;
    String? sId;
    String? cId;
    String? ayId;
    if (json['student_sections'] != null && (json['student_sections'] as List).isNotEmpty) {
      final sec = json['student_sections'][0];
      rNumber = sec['roll_number']?.toString();
      sId = sec['section_id'];
      ayId = sec['academic_year_id'];
      final secDetails = sec['sections'];
      if (secDetails != null) {
        sName = secDetails['name'];
        if (secDetails['classes'] != null) {
          cName = secDetails['classes']['name'];
          cId = secDetails['classes']['id'];
        }
      }
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      name: (json['full_name'] ?? json['name']) as String? ?? 'Guest User',
      email: json['email'] as String? ?? '',
      tempPassword: json['tempPassword'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['profile_image_url'] as String?,
      role: UserRole.values.firstWhere(
        (r) {
          final roleString = json['role'] as String?;
          if (roleString == 'super_admin' && r == UserRole.superAdmin) return true;
          return r.name == roleString;
        },
        orElse: () => UserRole.student,
      ),
      starsCount: json['starsCount'] as int? ?? 0,
      completedLevels: json['completedLevels'] as int? ?? 0,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      status: json['status'] as String?,
      address: json['address'] as String?,
      domainId: json['domain_id'] as String?,
      mustChangePassword: json['must_change_password'] as bool? ?? false,
      rollNumber: rNumber,
      className: cName,
      sectionName: sName,
      classId: cId,
      sectionId: sId,
      academicYearId: ayId,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      qualification: json['qualification'] as String?,
      experience: json['experience'] != null ? int.tryParse(json['experience'].toString()) : null,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth']) : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    int? starsCount,
    int? completedLevels,
    String? phone,
    String? gender,
    String? status,
    String? address,
    String? domainId,
    bool? mustChangePassword,
    String? city,
    String? state,
    String? country,
    String? qualification,
    int? experience,
    DateTime? dateOfBirth,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      starsCount: starsCount ?? this.starsCount,
      completedLevels: completedLevels ?? this.completedLevels,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      address: address ?? this.address,
      domainId: domainId ?? this.domainId,
      tempPassword: tempPassword,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
