class EnquiryModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? message;
  final String? status;
  final String? domainId;
  final String? domainName;
  final DateTime createdAt;

  EnquiryModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.message,
    this.status,
    this.domainId,
    this.domainName,
    required this.createdAt,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String?,
      domainId: json['domain_id'] as String?,
      domainName: json['domains'] != null ? json['domains']['name'] as String? : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      'status': status,
      'domain_id': domainId,
    };
  }
}
