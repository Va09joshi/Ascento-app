class SectionModel {
  final String id;
  final String name;
  final String classId;
  final int maxStudents;
  final String? timetablePdfUrl;
  final String? teacherId;
  final String? teacherName;

  const SectionModel({
    required this.id,
    required this.name,
    required this.classId,
    required this.maxStudents,
    this.timetablePdfUrl,
    this.teacherId,
    this.teacherName,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      classId: json['class_id'] as String? ?? '',
      maxStudents: json['max_students'] as int? ?? 0,
      timetablePdfUrl: json['timetable_pdf_url'] as String?,
      teacherId: json['teacher_id'] as String?,
      teacherName: json['users'] != null ? json['users']['full_name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'class_id': classId,
      'max_students': maxStudents,
      'timetable_pdf_url': timetablePdfUrl,
      'teacher_id': teacherId,
    };
  }
}
