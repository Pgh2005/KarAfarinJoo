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

class GradeSection {
  final String key;
  final String title;
  final String legacyKey;
  final List<GradeComponent> components;

  const GradeSection({
    required this.key,
    required this.title,
    required this.legacyKey,
    required this.components,
  });

  double get maxScore =>
      components.fold(0, (sum, component) => sum + component.maxScore);
}

class ParticipationEntry {
  final DateTime date;
  final double score;

  const ParticipationEntry({required this.date, required this.score});

  String get dateKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  factory ParticipationEntry.fromMap(Map<String, dynamic> map) {
    return ParticipationEntry(
      date: DateTime.parse(map['date'] as String),
      score: StudentGrade._parseScore(map['score'])!,
    );
  }

  Map<String, dynamic> toMap() => {'date': dateKey, 'score': score};
}

class StudentGrade {
  static const participationMaxScore = 20.0;

  static const sections = [
    GradeSection(
      key: 'slogan',
      title: 'شعار',
      legacyKey: 'slogan',
      components: [
        GradeComponent(key: 'slogan_life', label: 'زندگی', maxScore: 1),
        GradeComponent(key: 'slogan_business', label: 'کسب', maxScore: 1),
      ],
    ),
    GradeSection(
      key: 'exam',
      title: 'امتحان',
      legacyKey: 'exam',
      components: [GradeComponent(key: 'exam', label: 'امتحان', maxScore: 20)],
    ),
    GradeSection(
      key: 'growth_plan',
      title: 'برنامه رشد',
      legacyKey: 'growth_plan',
      components: [
        GradeComponent(key: 'growth_plan_table', label: 'جدول', maxScore: 5),
        GradeComponent(
          key: 'growth_plan_class_improvement',
          label: 'بهبود کلاس',
          maxScore: 5,
        ),
      ],
    ),
    GradeSection(
      key: 'products',
      title: 'محصولات',
      legacyKey: 'products',
      components: [
        GradeComponent(key: 'products_table', label: 'جدول', maxScore: 3),
        GradeComponent(key: 'products_new', label: 'جدید', maxScore: 4),
        GradeComponent(
          key: 'products_presentation',
          label: 'ارائه',
          maxScore: 10,
        ),
      ],
    ),
    GradeSection(
      key: 'business_17',
      title: 'طرح کسب‌وکار',
      legacyKey: 'business_17',
      components: [
        GradeComponent(key: 'business_17_table', label: 'جدول', maxScore: 3),
        GradeComponent(key: 'business_17_quality', label: 'عیار', maxScore: 4),
        GradeComponent(
          key: 'business_17_presentation',
          label: 'ارائه',
          maxScore: 10,
        ),
      ],
    ),
    GradeSection(
      key: 'book',
      title: 'کتاب',
      legacyKey: 'book',
      components: [
        GradeComponent(key: 'book_presentation', label: 'ارائه', maxScore: 10),
        GradeComponent(key: 'book_sentences', label: 'جملات', maxScore: 3),
        GradeComponent(key: 'book_question', label: 'سوال', maxScore: 1),
      ],
    ),
    GradeSection(
      key: 'talent',
      title: 'استعدادیابی',
      legacyKey: 'talent',
      components: [
        GradeComponent(key: 'talent_test', label: 'تست', maxScore: 3),
        GradeComponent(key: 'talent_intelligence', label: 'هوش', maxScore: 1),
      ],
    ),
    GradeSection(
      key: 'business_6',
      title: 'ارزیابی کاسب و ارتباط',
      legacyKey: 'business_6',
      components: [
        GradeComponent(key: 'business_6_trader', label: 'کاسب', maxScore: 3),
        GradeComponent(key: 'business_6_related', label: 'مرتبط', maxScore: 3),
      ],
    ),
  ];

  static List<GradeComponent> get components =>
      sections.expand((section) => section.components).toList(growable: false);

  final String classId;
  final String studentId;
  final Map<String, double?> scores;
  final Map<String, double?> legacyScores;
  final List<ParticipationEntry> participationEntries;
  final bool hasNewParticipationData;
  final List<DateTime> attendanceDates;
  final double? extracurricularScore;

  StudentGrade({
    required this.classId,
    required this.studentId,
    required Map<String, double?> scores,
    Map<String, double?> legacyScores = const {},
    List<ParticipationEntry> participationEntries = const [],
    bool hasNewParticipationData = false,
    List<DateTime> attendanceDates = const [],
    this.extracurricularScore,
  }) : scores = {
         for (final component in components)
           component.key: scores[component.key],
       },
       legacyScores = {
         for (final section in sections)
           section.legacyKey: legacyScores[section.legacyKey],
         'class_participation': legacyScores['class_participation'],
       },
       participationEntries = List.unmodifiable(
         participationEntries.toList()
           ..sort((a, b) => a.date.compareTo(b.date)),
       ),
       attendanceDates = List.unmodifiable(
         attendanceDates.toList()..sort((a, b) => a.compareTo(b)),
       ),
       hasNewParticipationData =
           hasNewParticipationData || participationEntries.isNotEmpty;

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
    final rawParticipation = map['participation_sessions'];
    final participationEntries = rawParticipation is List
        ? rawParticipation
              .map(
                (entry) => ParticipationEntry.fromMap(
                  Map<String, dynamic>.from(entry as Map),
                ),
              )
              .toList()
        : <ParticipationEntry>[];

    return StudentGrade(
      classId: map['class_id'] as String,
      studentId: map['student_id'] as String,
      scores: {
        for (final component in components)
          component.key: _parseScore(map[component.key]),
      },
      legacyScores: {
        for (final section in sections)
          section.legacyKey: _parseScore(map[section.legacyKey]),
        'class_participation': _parseScore(map['class_participation']),
      },
      participationEntries: participationEntries,
      hasNewParticipationData: map['participation_sessions'] != null,
      attendanceDates: (map['attendance_dates'] as List<dynamic>? ?? const [])
          .map((date) => DateTime.parse(date as String))
          .toList(),
      extracurricularScore: _parseScore(map['extracurricular']),
    );
  }

  static double? _parseScore(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  double get manualParticipationTotal {
    if (hasNewParticipationData) {
      return participationEntries.fold(0, (sum, entry) => sum + entry.score);
    }
    return legacyScores['class_participation'] ?? 0;
  }

  double get participationTotal => manualParticipationTotal + attendanceScore;

  double get attendanceScore => attendanceDates.length.toDouble();

  List<ParticipationEntry> get datedParticipationEntries {
    final entriesByDate = {
      for (final entry in participationEntries) entry.dateKey: entry,
    };

    for (final date in attendanceDates) {
      final key = _dateKey(date);
      final manualEntry = entriesByDate[key];
      entriesByDate[key] = ParticipationEntry(
        date: date,
        score: (manualEntry?.score ?? 0) + 1,
      );
    }

    return entriesByDate.values.toList()
      ..sort((first, second) => first.date.compareTo(second.date));
  }

  double scoreForSection(GradeSection section) {
    final hasDetailedScore = section.components.any(
      (component) => scores[component.key] != null,
    );
    if (!hasDetailedScore) return legacyScores[section.legacyKey] ?? 0;
    return section.components.fold(
      0.0,
      (sum, component) => sum + (scores[component.key] ?? 0),
    );
  }

  bool hasLegacyScore(GradeSection section) =>
      legacyScores[section.legacyKey] != null &&
      section.components.every((component) => scores[component.key] == null);

  double get total =>
      sections.fold(0.0, (sum, section) => sum + scoreForSection(section)) +
      participationTotal +
      (extracurricularScore ?? 0);

  double get scoreOutOf22 => total / 5;

  int get enteredComponents {
    final enteredSections = sections
        .where(
          (section) =>
              section.components.every(
                (component) => scores[component.key] != null,
              ) ||
              hasLegacyScore(section),
        )
        .length;
    final hasParticipation =
        participationEntries.isNotEmpty ||
        attendanceScore > 0 ||
        (!hasNewParticipationData &&
            legacyScores['class_participation'] != null);
    return enteredSections + (hasParticipation ? 1 : 0);
  }

  bool get isComplete =>
      sections.every(
        (section) =>
            section.components.every(
              (component) => scores[component.key] != null,
            ) ||
            hasLegacyScore(section),
      ) &&
      (participationEntries.isNotEmpty ||
            attendanceScore > 0 ||
            (!hasNewParticipationData &&
                legacyScores['class_participation'] != null));

  bool get isEmpty =>
      sections.every(
        (section) =>
            section.components.every(
              (component) => scores[component.key] == null,
            ) &&
            legacyScores[section.legacyKey] == null,
      ) &&
      participationEntries.isEmpty &&
      attendanceScore == 0 &&
      (hasNewParticipationData ||
          legacyScores['class_participation'] == null) &&
      extracurricularScore == null;

  String? validate() {
    for (final component in components) {
      final score = scores[component.key];
      if (score != null &&
          (!score.isFinite || score < 0 || score > component.maxScore)) {
        return 'نمرهٔ ${component.label} باید بین ۰ و ${component.maxScore} باشد.';
      }
    }
    if (participationEntries.any(
      (entry) => !entry.score.isFinite || entry.score < 0,
    )) {
      return 'نمرهٔ هر جلسه نمی‌تواند منفی باشد.';
    }
    if (!attendanceScore.isFinite || attendanceScore < 0) {
      return 'امتیاز حضور نمی‌تواند منفی یا نامعتبر باشد.';
    }
    if (participationTotal > participationMaxScore) {
      return 'مجموع نمره‌های مشارکت و حضور نمی‌تواند از ۲۰ بیشتر شود.';
    }
    if (participationEntries.map((entry) => entry.dateKey).toSet().length !=
        participationEntries.length) {
      return 'برای یک تاریخ فقط یک نمرهٔ مشارکت ثبت کنید.';
    }
    if (extracurricularScore != null &&
        (!extracurricularScore!.isFinite || extracurricularScore! < 0)) {
      return 'نمرهٔ فوق‌برنامه نمی‌تواند منفی باشد.';
    }
    return null;
  }

  StudentGrade copyWithScore(String componentKey, double? score) {
    return StudentGrade(
      classId: classId,
      studentId: studentId,
      scores: {...scores, componentKey: score},
      legacyScores: legacyScores,
      participationEntries: participationEntries,
      hasNewParticipationData: hasNewParticipationData,
      attendanceDates: attendanceDates,
      extracurricularScore: extracurricularScore,
    );
  }

  StudentGrade copyWithParticipationEntries(List<ParticipationEntry> entries) {
    return StudentGrade(
      classId: classId,
      studentId: studentId,
      scores: scores,
      legacyScores: legacyScores,
      participationEntries: entries,
      hasNewParticipationData: true,
      attendanceDates: attendanceDates,
      extracurricularScore: extracurricularScore,
    );
  }

  StudentGrade copyWithExtracurricular(double? score) {
    return StudentGrade(
      classId: classId,
      studentId: studentId,
      scores: scores,
      legacyScores: legacyScores,
      participationEntries: participationEntries,
      hasNewParticipationData: hasNewParticipationData,
      attendanceDates: attendanceDates,
      extracurricularScore: score,
    );
  }

  Map<String, dynamic> toMap({required String updatedBy}) {
    return {
      'class_id': classId,
      'student_id': studentId,
      ...scores,
      for (final section in sections)
        if (section.legacyKey != 'exam')
          section.legacyKey:
              section.components.any(
                (component) => scores[component.key] != null,
              )
              ? null
              : legacyScores[section.legacyKey],
      'class_participation': hasNewParticipationData
          ? null
          : legacyScores['class_participation'],
      'participation_sessions': hasNewParticipationData
          ? participationEntries.map((entry) => entry.toMap()).toList()
          : null,
      'extracurricular': extracurricularScore,
      'updated_by': updatedBy,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
