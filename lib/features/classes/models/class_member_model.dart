class ClassMemberModel {
  final String id;
  final String classId;
  final String studentId;
  final DateTime joinedAt;

  const ClassMemberModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.joinedAt,
  });

  factory ClassMemberModel.fromMap(Map<String, dynamic> map) {
    return ClassMemberModel(
      id: map['id'] as String,
      classId: map['class_id'] as String,
      studentId: map['student_id'] as String,
      joinedAt: DateTime.parse(map['joined_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'class_id': classId,
      'student_id': studentId,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
