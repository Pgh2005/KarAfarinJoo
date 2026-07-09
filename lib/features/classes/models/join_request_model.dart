enum JoinRequestStatus {
  pending,
  approved,
  rejected;

  static JoinRequestStatus fromValue(String value) {
    switch (value) {
      case 'pending':
        return JoinRequestStatus.pending;
      case 'approved':
        return JoinRequestStatus.approved;
      case 'rejected':
        return JoinRequestStatus.rejected;
      default:
        throw ArgumentError('Invalid join request status: $value');
    }
  }

  String get value {
    switch (this) {
      case JoinRequestStatus.pending:
        return 'pending';
      case JoinRequestStatus.approved:
        return 'approved';
      case JoinRequestStatus.rejected:
        return 'rejected';
    }
  }
}

class JoinRequestModel {
  final String id;
  final String classId;
  final String studentId;
  final JoinRequestStatus status;
  final String? message;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JoinRequestModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.status,
    this.message,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JoinRequestModel.fromMap(Map<String, dynamic> map) {
    return JoinRequestModel(
      id: map['id'] as String,
      classId: map['class_id'] as String,
      studentId: map['student_id'] as String,
      status: JoinRequestStatus.fromValue(map['status'] as String),
      message: map['message'] as String?,
      rejectionReason: map['rejection_reason'] as String?,
      reviewedBy: map['reviewed_by'] as String?,
      reviewedAt: map['reviewed_at'] == null
          ? null
          : DateTime.parse(map['reviewed_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'class_id': classId,
      'student_id': studentId,
      'status': status.value,
      'message': message,
      'rejection_reason': rejectionReason,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
