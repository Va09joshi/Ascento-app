import 'package:ascento_abacus/shared/models/user_model.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // If wrapped in standard success response (e.g. from backend)
    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>? ?? json;
    final Map<String, dynamic> session = data['session'] as Map<String, dynamic>? ?? {};

    return AuthResponse(
      accessToken: session['access_token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: session['refresh_token'] as String? ?? json['refreshToken'] as String? ?? '',
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
  }) {
    return AuthResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}
