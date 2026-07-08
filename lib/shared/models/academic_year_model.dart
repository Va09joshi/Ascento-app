class AcademicYearModel {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isCurrent;

  const AcademicYearModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
      'is_current': isCurrent,
    };
  }
}
