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
    };
  }

  // Parse from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: (json['full_name'] ?? json['name']) as String? ?? 'Guest User',
      email: json['email'] as String? ?? '',
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
    );
  }
}
