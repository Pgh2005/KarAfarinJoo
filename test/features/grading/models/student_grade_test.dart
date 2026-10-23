import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/grading/models/student_grade.dart';

void main() {
  group('StudentGrade', () {
    test('defines the PDF grade components with a total maximum of 110', () {
      final maxScore = StudentGrade.components.fold<double>(
        0,
        (sum, component) => sum + component.maxScore,
      );

      expect(StudentGrade.components, hasLength(9));
      expect(maxScore, 110);
    });

    test('calculates totals and the equivalent score out of 22', () {
      var grade = StudentGrade.empty(classId: 'class-1', studentId: 'student-1')
          .copyWithScore('slogan', 2)
          .copyWithScore('exam', 18)
          .copyWithScore('growth_plan', 9)
          .copyWithScore('products', 16)
          .copyWithScore('business_17', 15)
          .copyWithScore('book', 12)
          .copyWithScore('talent', 4)
          .copyWithScore('business_6', 5)
          .copyWithScore('class_participation', 19);

      expect(grade.total, 100);
      expect(grade.scoreOutOf22, 20);
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
        expect(partial.enteredComponents, 1);
        expect(partial.total, 0);
      },
    );

    test('rejects scores outside the component maximum', () {
      final grade = StudentGrade.empty(
        classId: 'class-1',
        studentId: 'student-1',
      ).copyWithScore('exam', 20.01);

      expect(grade.validate(), isNotNull);
    });

    test('serializes nullable component scores for Supabase', () {
      final grade = StudentGrade.empty(
        classId: 'class-1',
        studentId: 'student-1',
      ).copyWithScore('exam', 17.5);

      final row = grade.toMap(updatedBy: 'teacher-1');

      expect(row['class_id'], 'class-1');
      expect(row['student_id'], 'student-1');
      expect(row['exam'], 17.5);
      expect(row['slogan'], isNull);
      expect(row['updated_by'], 'teacher-1');
      expect(row['updated_at'], isA<String>());
    });
  });
}
