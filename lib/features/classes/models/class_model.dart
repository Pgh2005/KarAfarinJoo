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
  final DateTime updatedAt;

  const ClassModel({
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
    required this.updatedAt,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] as String,
      teacherId: map['teacher_id'] as String,
      title: map['title'] as String,
      courseCode: map['course_code'] as String,
      semester: map['semester'] as String,
      description: map['description'] as String?,
      joinCode: map['join_code'] as String,
      maxStudents: (map['max_students'] as int?) ?? 0,
      isActive: (map['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'title': title,
      'course_code': courseCode,
      'semester': semester,
      'description': description,
      'join_code': joinCode,
      'max_students': maxStudents,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
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

  ClassModel copyWith({
    String? id,
    String? teacherId,
    String? title,
    String? courseCode,
    String? semester,
    String? description,
    String? joinCode,
    int? maxStudents,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      courseCode: courseCode ?? this.courseCode,
      semester: semester ?? this.semester,
      description: description ?? this.description,
      joinCode: joinCode ?? this.joinCode,
      maxStudents: maxStudents ?? this.maxStudents,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
