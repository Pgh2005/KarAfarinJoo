import 'join_request_model.dart';

class JoinRequestWithProfile {
  final JoinRequestModel request;
  final String? studentName;
  final String? studentEmail;
  final String className;

  const JoinRequestWithProfile({
    required this.request,
    this.studentName,
    this.studentEmail,
    required this.className,
  });

  factory JoinRequestWithProfile.fromMap(Map<String, dynamic> map) {
    // Handle profiles - could be a Map or a List with one item
    Map<String, dynamic>? profileMap;
    final profileData = map['profiles'];
    if (profileData is Map<String, dynamic>) {
      profileMap = profileData;
    } else if (profileData is List && profileData.isNotEmpty) {
      profileMap = profileData.first as Map<String, dynamic>?;
    }

    // Handle classes - could be a Map or a List
    Map<String, dynamic>? classMap;
    final classData = map['classes'];

    if (classData is Map<String, dynamic>) {
      classMap = classData;
    } else if (classData is List && classData.isNotEmpty) {
      classMap = classData.first as Map<String, dynamic>?;
    }

    return JoinRequestWithProfile(
      request: JoinRequestModel.fromMap(map),
      studentName: profileMap?['full_name'] as String?,
      studentEmail: profileMap?['email'] as String?,
      className: (classMap?['title'] as String?) ?? '',
    );
  }
}
