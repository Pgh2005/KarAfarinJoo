import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/grading/models/student_grade.dart';

void main() {
  group('StudentGrade', () {
    test('subcategories preserve the 110-point base total', () {
      final fixedMax = StudentGrade.components.fold<double>(
        0,
        (sum, component) => sum + component.maxScore,
      );

      expect(StudentGrade.sections, hasLength(8));
      expect(StudentGrade.components, hasLength(18));
      expect(fixedMax, 90);
      expect(fixedMax + StudentGrade.participationMaxScore, 110);
      expect(
        StudentGrade.sections.map((section) => section.title).toSet(),
        hasLength(StudentGrade.sections.length),
      );
      expect(StudentGrade.sections[4].title, 'طرح کسب‌وکار');
      expect(StudentGrade.sections[7].title, 'ارزیابی کاسب و ارتباط');
    });

    test('calculates the score out of 22 by dividing the total by five', () {
      final grade = _completeGrade(extracurricularScore: 10);

      expect(grade.total, 120);
      expect(grade.scoreOutOf22, 24);
      expect(grade.isComplete, isTrue);
      expect(grade.isEmpty, isFalse);
      expect(grade.validate(), isNull);
    });

    test(
      'allows empty and partial grades without treating them as complete',
      () {
        final empty = StudentGrade.empty(
          classId: 'class-1',
          studentId: 'student-1',
        );
        final partial = empty.copyWithScore('exam', 0);

        expect(empty.isEmpty, isTrue);
        expect(empty.isComplete, isFalse);
        expect(partial.isEmpty, isFalse);
        expect(partial.isComplete, isFalse);
        expect(partial.total, 0);
      },
    );

    test('validates every subscore against its own maximum', () {
      final grade = StudentGrade.empty(
        classId: 'class-1',
        studentId: 'student-1',
      ).copyWithScore('business_17_quality', 4.01);

      expect(grade.validate(), isNotNull);
    });

    test('sums participation sessions but rejects totals over twenty', () {
      final withinLimit =
          StudentGrade.empty(
            classId: 'class-1',
            studentId: 'student-1',
          ).copyWithParticipationEntries([
            ParticipationEntry(date: DateTime(2026, 1, 1), score: 8),
            ParticipationEntry(date: DateTime(2026, 1, 8), score: 12),
          ]);
      final overLimit = withinLimit.copyWithParticipationEntries([
        ...withinLimit.participationEntries,
        ParticipationEntry(date: DateTime(2026, 1, 15), score: 0.01),
      ]);

      expect(withinLimit.participationTotal, 20);
      expect(withinLimit.validate(), isNull);
      expect(overLimit.validate(), contains('۲۰'));
    });

    test('rejects duplicate participation dates', () {
      final grade =
          StudentGrade.empty(
            classId: 'class-1',
            studentId: 'student-1',
          ).copyWithParticipationEntries([
            ParticipationEntry(date: DateTime(2026, 1, 1), score: 2),
            ParticipationEntry(date: DateTime(2026, 1, 1), score: 3),
          ]);

      expect(grade.validate(), contains('تاریخ'));
    });

    test('combines attendance points with manual participation within 20', () {
      final grade = StudentGrade.fromMap({
        'class_id': 'class-1',
        'student_id': 'student-1',
        'participation_sessions': [
          {'date': '2026-01-01', 'score': 16},
        ],
        'attendance_score': 4,
      });

      expect(grade.manualParticipationTotal, 16);
      expect(grade.participationTotal, 20);
      expect(grade.validate(), isNull);
      expect(
        grade.toMap(updatedBy: 'teacher-1').containsKey('attendance_score'),
        isFalse,
      );
    });

    test(
      'rejects manual participation that exceeds the limit with attendance',
      () {
        final grade = StudentGrade.fromMap({
          'class_id': 'class-1',
          'student_id': 'student-1',
          'participation_sessions': [
            {'date': '2026-01-01', 'score': 19},
          ],
          'attendance_score': 2,
        });

        expect(grade.validate(), contains('حضور'));
      },
    );

    test('counts attendance-only grades as non-empty participation', () {
      final grade = StudentGrade.fromMap({
        'class_id': 'class-1',
        'student_id': 'student-1',
        'attendance_score': 1,
      });

      expect(grade.isEmpty, isFalse);
      expect(grade.participationTotal, 1);
    });

    test('keeps legacy scores until details replace that section', () {
      final legacy = StudentGrade.fromMap({
        'class_id': 'class-1',
        'student_id': 'student-1',
        'growth_plan': 8,
        'class_participation': 5,
      });
      final detailed = legacy.copyWithScore('growth_plan_table', 3);

      expect(legacy.scoreForSection(StudentGrade.sections[2]), 8);
      expect(legacy.participationTotal, 5);
      expect(detailed.scoreForSection(StudentGrade.sections[2]), 3);
      expect(legacy.toMap(updatedBy: 'teacher-1')['growth_plan'], 8);
      expect(detailed.toMap(updatedBy: 'teacher-1')['growth_plan'], isNull);
      expect(
        legacy.toMap(updatedBy: 'teacher-1')['participation_sessions'],
        isNull,
      );
    });

    test(
      'keeps an explicitly cleared session list separate from legacy scores',
      () {
        final legacy = StudentGrade.fromMap({
          'class_id': 'class-1',
          'student_id': 'student-1',
          'class_participation': 5,
        });
        final withSession = legacy.copyWithParticipationEntries([
          ParticipationEntry(date: DateTime(2026, 1, 1), score: 3),
        ]);
        final cleared = withSession.copyWithParticipationEntries(const []);
        final row = cleared.toMap(updatedBy: 'teacher-1');

        expect(withSession.participationTotal, 3);
        expect(cleared.participationTotal, 0);
        expect(row['participation_sessions'], isEmpty);
        expect(row['class_participation'], isNull);
      },
    );

    test(
      'serializes sub-scores, session dates, and uncapped extracurricular',
      () {
        final grade = _completeGrade(
          extracurricularScore: 25,
        ).copyWithScore('products_new', 2.5);
        final row = grade.toMap(updatedBy: 'teacher-1');
        final sessions =
            row['participation_sessions'] as List<Map<String, dynamic>>;

        expect(row['class_id'], 'class-1');
        expect(row['student_id'], 'student-1');
        expect(row['products_new'], 2.5);
        expect(row['slogan_life'], 1);
        expect(row['extracurricular'], 25);
        expect(sessions.single, {'date': '2026-01-01', 'score': 20});
        expect(row['updated_by'], 'teacher-1');
        expect(row['updated_at'], isA<String>());
      },
    );
  });
}

StudentGrade _completeGrade({double extracurricularScore = 0}) {
  return StudentGrade(
    classId: 'class-1',
    studentId: 'student-1',
    scores: {
      for (final component in StudentGrade.components)
        component.key: component.maxScore,
    },
    participationEntries: [
      ParticipationEntry(date: DateTime(2026, 1, 1), score: 20),
    ],
    extracurricularScore: extracurricularScore,
  );
}
