enum UserRole { student, professor }

class Profile {
  final String id;
  final UserRole role;
  final String email;
  final String fullName;
  final String? studentNumber;
  final String? teacherNumber;
  final String? phone;
  final String? major;
  final String? department;
  final String? bio;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.role,
    required this.email,
    required this.fullName,
    this.studentNumber,
    this.teacherNumber,
    this.phone,
    this.major,
    this.department,
    this.bio,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      role: json['role'] == 'professor' ? UserRole.professor : UserRole.student,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      studentNumber: json['student_number'] as String?,
      teacherNumber: json['teacher_number'] as String?,
      phone: json['phone'] as String?,
      major: json['major'] as String?,
      department: json['department'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role == UserRole.professor ? 'professor' : 'student',
      'email': email,
      'full_name': fullName,
      'student_number': studentNumber,
      'teacher_number': teacherNumber,
      'phone': phone,
      'major': major,
      'department': department,
      'bio': bio,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }
}
