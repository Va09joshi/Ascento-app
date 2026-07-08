class ClassModel {
  final String id;
  final String name;
  final int orderIndex;

  const ClassModel({
    required this.id,
    required this.name,
    required this.orderIndex,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order_index': orderIndex,
    };
  }
}
