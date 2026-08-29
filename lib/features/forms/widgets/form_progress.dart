import 'package:karafarini/features/forms/pages/page1/models/personal_info_model.dart';
import 'package:karafarini/features/forms/pages/page2/models/talent_model.dart';
import 'package:karafarini/features/forms/pages/page3/models/values_model.dart';
import 'package:karafarini/features/forms/pages/page4/models/business_selection_model.dart';
import 'package:karafarini/features/forms/pages/page5/models/product_priority_model.dart';
import 'package:karafarini/features/forms/pages/page6/models/growth_table_model.dart';

/// Simple container for progress data of a single form.
class FormProgress {
  final int filled;
  final int total;

  const FormProgress({required this.filled, required this.total});

  double get percent => total == 0 ? 0.0 : (filled / total * 100).clamp(0, 100);

  bool get isComplete => filled >= total && total > 0;
}

/// Extension on PersonalInfoModel (page1) to compute progress.
extension PersonalInfoProgress on PersonalInfoModel {
  FormProgress get progress {
    final fields = <String>[
      firstName,
      lastName,
      contact,
      neighborhood,
      major,
      degree,
      satisfiedMajor,
      majorReason,
      ifReturn,
      businessTitle,
      businessSatisfied,
      businessSlogan,
      lifeSlogan,
      valueOrientation,
    ];
    final filled = fields.where((f) => f.trim().isNotEmpty).length;
    return FormProgress(filled: filled, total: fields.length);
  }
}

/// Extension on TalentModel (page2) to compute progress.
extension TalentProgress on TalentModel {
  FormProgress get progress {
    int filled = 0;
    int total = 0;

    // 5 main text fields
    final mainFields = [
      highestCategory,
      lowestTalent,
      twoDimType,
      fourDimType,
      bestTeam,
    ];
    total += mainFields.length;
    filled += mainFields.where((f) => f.trim().isNotEmpty).length;

    // 5 rows × 2 fields each (title + description)
    for (final row in rows) {
      total += 2;
      if (row.title.trim().isNotEmpty) filled++;
      if (row.description.trim().isNotEmpty) filled++;
    }

    return FormProgress(filled: filled, total: total);
  }
}

/// Extension on ValuesModel (page3) to compute progress.
extension ValuesProgress on ValuesModel {
  FormProgress get progress {
    final filled = valuesList.where((v) => v.trim().isNotEmpty).length;
    return FormProgress(filled: filled, total: valuesList.length);
  }
}

/// Extension on BusinessSelectionModel (page4) to compute progress.
extension BusinessSelectionProgress on BusinessSelectionModel {
  FormProgress get progress {
    int filled = 0;
    int total = 0;

    // 3 business names
    total += 3;
    filled += bizNames.where((n) => n.trim().isNotEmpty).length;

    // Each criterion: weight + 3 scores
    for (final c in criteria) {
      total += 4; // weight + 3 scores
      if (c.weight > 0) filled++;
      for (final s in c.scores) {
        if (s.trim().isNotEmpty) filled++;
      }
    }

    return FormProgress(filled: filled, total: total);
  }
}

/// Extension on ProductPriorityModel (page5) to compute progress.
extension ProductPriorityProgress on ProductPriorityModel {
  FormProgress get progress {
    int filled = 0;
    int total = 0;

    // 4 product names
    total += 4;
    filled += productNames.where((n) => n.trim().isNotEmpty).length;

    // Each criterion: weight + 4 scores
    for (final c in criteria) {
      total += 5; // weight + 4 scores
      if (c.weight > 0) filled++;
      for (final s in c.scores) {
        if (s.trim().isNotEmpty) filled++;
      }
    }

    return FormProgress(filled: filled, total: total);
  }
}

/// Extension on growth periods list (page6) to compute progress.
extension GrowthTableProgress on List<GrowthPeriod> {
  FormProgress get progress {
    int filled = 0;
    int total = 0;

    for (final period in this) {
      // 2 date fields
      total += 2;
      if (period.startDate.trim().isNotEmpty) filled++;
      if (period.targetDate.trim().isNotEmpty) filled++;

      // Each metric: currentValue + target + result
      for (final metric in period.metrics) {
        total += 3;
        if (metric.currentValue.trim().isNotEmpty) filled++;
        if (metric.target.trim().isNotEmpty) filled++;
        if (metric.result.trim().isNotEmpty) filled++;
      }
    }

    // If no periods exist, treat as 0/0 (no progress to show)
    if (total == 0) {
      return const FormProgress(filled: 0, total: 0);
    }

    return FormProgress(filled: filled, total: total);
  }
}
