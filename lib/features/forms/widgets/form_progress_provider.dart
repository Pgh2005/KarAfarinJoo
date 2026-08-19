import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/features/forms/pages/page1/providers/personal_info_provider.dart';
import 'package:karafarini/features/forms/pages/page2/providers/talent_provider.dart';
import 'package:karafarini/features/forms/pages/page3/providers/values_provider.dart';
import 'package:karafarini/features/forms/pages/page4/providers/business_selection_provider.dart';
import 'package:karafarini/features/forms/pages/page5/providers/product_priority_provider.dart';
import 'package:karafarini/features/forms/pages/page6/providers/growth_table_provider.dart';
import 'package:karafarini/features/forms/widgets/form_progress.dart';

/// Holds progress data for all 6 forms.
class AllFormsProgress {
  final FormProgress page1;
  final FormProgress page2;
  final FormProgress page3;
  final FormProgress page4;
  final FormProgress page5;
  final FormProgress page6;

  const AllFormsProgress({
    required this.page1,
    required this.page2,
    required this.page3,
    required this.page4,
    required this.page5,
    required this.page6,
  });

  /// List of progress for easy iteration.
  List<FormProgress> get all => [page1, page2, page3, page4, page5, page6];

  /// Overall progress across all forms.
  FormProgress get overall {
    int filled = 0;
    int total = 0;
    for (final p in all) {
      filled += p.filled;
      total += p.total;
    }
    if (total == 0) return const FormProgress(filled: 0, total: 0);
    return FormProgress(filled: filled, total: total);
  }
}

/// Provider that computes progress for all 6 forms.
final allFormsProgressProvider =
    Provider.family<AllFormsProgress, (String, String)>((ref, params) {
  final (classId, studentId) = params;
  final fp = FormParams(classId: classId, studentId: studentId);

  final p1 = ref.watch(personalInfoNotifierProvider(fp));
  final p2 = ref.watch(talentProvider(TalentParams(
    classId: classId,
    studentId: studentId,
  )));
  final p3 = ref.watch(valuesNotifierProvider(fp));
  final p4 = ref.watch(businessSelectionNotifierProvider(fp));
  final p5 = ref.watch(productPriorityNotifierProvider(fp));
  final p6 = ref.watch(growthTableProvider(GrowthTableParams(
    studentId: studentId,
    classId: classId,
  )));

  return AllFormsProgress(
    page1: p1.whenOrNull(data: (m) => m.progress) ??
        const FormProgress(filled: 0, total: 1),
    page2: p2.whenOrNull(data: (m) => m.progress) ??
        const FormProgress(filled: 0, total: 1),
    page3: p3.whenOrNull(data: (m) => m.progress) ??
        const FormProgress(filled: 0, total: 1),
    page4: p4.whenOrNull(data: (m) => m.progress) ??
        const FormProgress(filled: 0, total: 1),
    page5: p5.whenOrNull(data: (m) => m.progress) ??
        const FormProgress(filled: 0, total: 1),
    page6: p6.whenOrNull(data: (m) => m.progress) ??
        const FormProgress(filled: 0, total: 1),
  );
});
