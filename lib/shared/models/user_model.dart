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

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.starsCount = 0,
    this.completedLevels = 0,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      starsCount: starsCount ?? this.starsCount,
      completedLevels: completedLevels ?? this.completedLevels,
    );
  }
}
