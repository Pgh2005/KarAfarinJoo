class ClassModel {
  final String id;
  final String teacherId;
  final String title;
  final String courseCode;
  final String semester;
  final String? description;
  final String joinCode;
  final int maxStudents;
  final DateTime createdAt;
  final DateTime updatedAt;
  // برای راحتی نمایش نام استاد در سمت دانشجو:
  final String? teacherName;

  ClassModel({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.courseCode,
    required this.semester,
    this.description,
    required this.joinCode,
    required this.maxStudents,
    required this.createdAt,
    required this.updatedAt,
    this.teacherName,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      title: json['title'] as String,
      courseCode: json['course_code'] as String,
      semester: json['semester'] as String,
      description: json['description'] as String?,
      joinCode: json['join_code'] as String,
      maxStudents: json['max_students'] as int? ?? 40,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      teacherName: json['profiles'] != null
          ? json['profiles']['full_name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'title': title,
      'course_code': courseCode,
      'semester': semester,
      'description': description,
      'join_code': joinCode,
      'max_students': maxStudents,
    };
  }
}
