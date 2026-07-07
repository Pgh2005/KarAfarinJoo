class ClassModel {
  final String id;
  final String teacherId;
  final String title;
  final String courseCode;
  final String semester;
  final String? description;
  final String joinCode;
  final int maxStudents;
  final bool isActive;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.courseCode,
    required this.semester,
    this.description,
    required this.joinCode,
    required this.maxStudents,
    required this.isActive,
    required this.createdAt,
  }) : assert(courseCode.trim().isNotEmpty, 'courseCode cannot be empty'),
       assert(semester.trim().isNotEmpty, 'semester cannot be empty');

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'],
      teacherId: map['teacher_id'],
      title: map['title'],
      courseCode: map['course_code'],
      semester: map['semester'],
      description: map['description'],
      joinCode: map['join_code'],
      maxStudents: map['max_students'] ?? 0,
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacher_id': teacherId,
      'title': title,
      'course_code': courseCode,
      'semester': semester,
      'description': description,
      'join_code': joinCode,
      'max_students': maxStudents,
      'is_active': isActive,
    };
  }
}
