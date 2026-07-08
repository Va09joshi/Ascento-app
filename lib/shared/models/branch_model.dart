class BranchModel {
  final String id;
  final String name;
  final String city;
  final String phone;
  final String address;

  const BranchModel({
    required this.id,
    required this.name,
    required this.city,
    required this.phone,
    required this.address,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'phone': phone,
      'address': address,
    };
  }
}
