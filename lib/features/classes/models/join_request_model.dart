class JoinRequestModel {
  final String id;
  final String classId;
  final String studentId;
  final String status;
  final String? message;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime createdAt;

  JoinRequestModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.status,
    this.message,
    this.rejectionReason,
    this.reviewedBy,
    required this.createdAt,
  });

  factory JoinRequestModel.fromMap(Map<String, dynamic> map) {
    return JoinRequestModel(
      id: map['id'],
      classId: map['class_id'],
      studentId: map['student_id'],
      status: map['status'],
      message: map['message'],
      rejectionReason: map['rejection_reason'],
      reviewedBy: map['reviewed_by'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
