class GradeComponent {
  final String key;
  final String label;
  final double maxScore;

  const GradeComponent({
    required this.key,
    required this.label,
    required this.maxScore,
  });
}

class StudentGrade {
  static const components = [
    GradeComponent(key: 'slogan', label: 'شعار', maxScore: 2),
    GradeComponent(key: 'exam', label: 'امتحان', maxScore: 20),
    GradeComponent(key: 'growth_plan', label: 'برنامه رشد', maxScore: 10),
    GradeComponent(key: 'products', label: 'محصولات', maxScore: 17),
    GradeComponent(key: 'business_17', label: 'کسب‌وکار', maxScore: 17),
    GradeComponent(key: 'book', label: 'کتاب', maxScore: 14),
    GradeComponent(key: 'talent', label: 'استعدادیابی', maxScore: 4),
    GradeComponent(key: 'business_6', label: 'کسب‌وکار', maxScore: 6),
    GradeComponent(
      key: 'class_participation',
      label: 'مشارکت کلاسی',
      maxScore: 20,
    ),
  ];

  final String classId;
  final String studentId;
  final Map<String, double?> scores;

  StudentGrade({
    required this.classId,
    required this.studentId,
    required Map<String, double?> scores,
  }) : scores = {
         for (final component in components)
           component.key: scores[component.key],
       };

  factory StudentGrade.empty({
    required String classId,
    required String studentId,
  }) {
    return StudentGrade(
      classId: classId,
      studentId: studentId,
      scores: const {},
    );
  }

  factory StudentGrade.fromMap(Map<String, dynamic> map) {
    return StudentGrade(
      classId: map['class_id'] as String,
      studentId: map['student_id'] as String,
      scores: {
        for (final component in components)
          component.key: _parseScore(map[component.key]),
      },
    );
  }

  static double? _parseScore(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  double get total => scores.values.fold(0, (sum, score) => sum + (score ?? 0));

  double get scoreOutOf22 => total / 5;

  int get enteredComponents => scores.values.whereType<double>().length;

  bool get isComplete => enteredComponents == components.length;

  bool get isEmpty => enteredComponents == 0;

  String? validate() {
    for (final component in components) {
      final score = scores[component.key];
      if (score != null && (score < 0 || score > component.maxScore)) {
        return 'نمرهٔ ${component.label} باید بین ۰ و ${component.maxScore} باشد.';
      }
    }
    return null;
  }

  StudentGrade copyWithScore(String componentKey, double? score) {
    return StudentGrade(
      classId: classId,
      studentId: studentId,
      scores: {...scores, componentKey: score},
    );
  }

  Map<String, dynamic> toMap({required String updatedBy}) {
    return {
      'class_id': classId,
      'student_id': studentId,
      ...scores,
      'updated_by': updatedBy,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
