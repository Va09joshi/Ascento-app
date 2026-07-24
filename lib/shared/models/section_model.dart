class SectionModel {
  final String id;
  final String name;
  final String classId;
  final int maxStudents;
  final String? timetablePdfUrl;

  const SectionModel({
    required this.id,
    required this.name,
    required this.classId,
    required this.maxStudents,
    this.timetablePdfUrl,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      classId: json['class_id'] as String? ?? '',
      maxStudents: json['max_students'] as int? ?? 0,
      timetablePdfUrl: json['timetable_pdf_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'class_id': classId,
      'max_students': maxStudents,
      'timetable_pdf_url': timetablePdfUrl,
    };
  }
}
