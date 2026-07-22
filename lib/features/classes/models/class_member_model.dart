class ClassMemberModel {
  final String id;
  final String classId;
  final String studentId;
  final String? approvedBy;
  final String? requestId;
  final DateTime joinedAt;
  final String? studentName;
  final String? studentEmail;
  final String? studentNumber;

  const ClassMemberModel({
    required this.id,
    required this.classId,
    required this.studentId,
    this.approvedBy,
    this.requestId,
    required this.joinedAt,
    this.studentName,
    this.studentEmail,
    this.studentNumber,
  });

  factory ClassMemberModel.fromMap(Map<String, dynamic> map) {
    final profileMap = map['profiles'] as Map<String, dynamic>?;

    return ClassMemberModel(
      id: map['id'] as String,
      classId: map['class_id'] as String,
      studentId: map['student_id'] as String,
      approvedBy: map['approved_by'] as String?,
      requestId: map['request_id'] as String?,
      joinedAt: DateTime.parse(map['joined_at'] as String),
      studentName: profileMap?['full_name'] as String?,
      studentEmail: profileMap?['email'] as String?,
      studentNumber: profileMap?['student_number'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'class_id': classId,
      'student_id': studentId,
      'approved_by': approvedBy,
      'request_id': requestId,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
