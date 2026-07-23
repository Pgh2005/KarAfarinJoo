import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/state/app_state.dart';
import 'package:karafarini/features/forms/widgets/info_hint_box.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/forms/widgets/score_card.dart';
import 'package:karafarini/features/forms/widgets/section_card.dart';

class BusinessSelectionPage extends StatefulWidget {
  const BusinessSelectionPage({super.key});

  @override
  State<BusinessSelectionPage> createState() => _BusinessSelectionPageState();
}

class _BusinessSelectionPageState extends State<BusinessSelectionPage> {
  final bool isLoading = false;
  final bool isEnable = true;

  // نام ۳ کسب‌وکار که دانشجو وارد می‌کند
  final List<TextEditingController> _bizNameControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final c in _bizNameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// جمع امتیاز هر کسب‌وکار
  List<double> _calcTotals(BusinessSelectionState model) {
    return List.generate(3, (bizIndex) {
      return model.criteria.fold<double>(0.0, (
        double sum,
        BusinessCriterion item,
      ) {
        final raw = item.scores[bizIndex].replaceAll(',', '');
        final score = double.tryParse(raw) ?? 0.0;
        final weight = item.weight.toDouble();
        return sum + score.clamp(0.0, weight);
      });
    });
  }

  /// حداکثر امتیاز ممکن (جمع وزن‌ها)
  double _maxScore(BusinessSelectionState model) {
    return model.criteria.fold<double>(0.0, (
      double sum,
      BusinessCriterion item,
    ) {
      return sum + item.weight.toDouble();
    });
  }

  /// بررسی خطای یک فیلد خاص برای یک کسب‌وکار
  String? _fieldError(BusinessCriterion item, int bizIndex) {
    final raw = item.scores[bizIndex].replaceAll(',', '');
    final score = double.tryParse(raw);
    if (score == null && raw.isNotEmpty) return 'عدد وارد کنید';
    final weight = item.weight.toDouble();
    if (score != null && score > weight) return 'بیشتر از وزن ($weight)';
    // بررسی یکسان نبودن
    final others = List.generate(3, (i) => i)
        .where((i) => i != bizIndex)
        .map((i) => item.scores[i].replaceAll(',', ''))
        .where((v) => v.isNotEmpty)
        .map((v) => double.tryParse(v))
        .whereType<double>();
    if (score != null && others.contains(score)) return 'تکراری';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final BusinessSelectionState model = AppState().businessSelection;
    final totals = _calcTotals(model);
    final maxScore = _maxScore(model);

    // پیدا کردن برنده (بیشترین امتیاز)
    int winnerIndex = 0;
    for (int i = 1; i < 3; i++) {
      if (totals[i] > totals[winnerIndex]) winnerIndex = i;
    }
    final bool anyScore = totals.any((t) => t > 0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'انتخاب کسب‌و‌کار'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── نام‌گذاری کسب‌وکارها ──
              SectionCard(
                icon: Icons.business_outlined,
                title: 'نام کسب‌و‌کارها',
                children: [
                  const Text(
                    'ابتدا نام ۳ کسب‌و‌کار خود را وارد کنید',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: i < 2 ? 10 : 0),
                      child: TextField(
                        controller: _bizNameControllers[i],
                        decoration: InputDecoration(
                          labelText: 'کسب‌و‌کار ${i + 1}',
                          prefixIcon: Icon(
                            Icons.store_outlined,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── راهنما ──
              const InfoHintBox(
                text:
                    'امتیاز هر کسب‌و‌کار نباید از وزن آن معیار بیشتر باشد و نمی‌توانند با هم یکسان باشند.',
              ),

              const SizedBox(height: 16),

              // ── ردیف‌های معیار ──
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.criteria.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = model.criteria[index];
                  return _CriteriaRow(
                    item: item,
                    index: index,
                    bizNames: _bizNameControllers.map((c) => c.text).toList(),
                    getError: (bizIndex) => _fieldError(item, bizIndex),
                    onChanged: () => setState(() {}),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── جمع امتیازات ──
              SectionCard(
                icon: Icons.bar_chart_rounded,
                title: 'نتیجه امتیازات',
                children: [
                  ...List.generate(3, (i) {
                    final isWinner = anyScore && i == winnerIndex;
                    final percent = maxScore > 0
                        ? totals[i] / maxScore * 100
                        : 0.0;
                    final bizName = _bizNameControllers[i].text.isNotEmpty
                        ? _bizNameControllers[i].text
                        : 'کسب‌و‌کار ${i + 1}';

                    return Padding(
                      padding: EdgeInsets.only(bottom: i < 2 ? 12 : 0),
                      child: ScoreCard(
                        name: bizName,
                        score: totals[i],
                        percent: percent.toDouble(),
                        maxScore: maxScore,
                        isWinner: isWinner,
                        winnerLabel: 'این کسب‌و‌کار بالاترین امتیاز را دارد',
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 24),

              SaveButton(
                onSave: () {},
                isLoading: isLoading,
                isEnabled: isEnable,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Criteria Row ─────────────────────────────────────────────────────────────
class _CriteriaRow extends StatefulWidget {
  final BusinessCriterion item;
  final int index;
  final List<String> bizNames;
  final String? Function(int bizIndex) getError;
  final VoidCallback onChanged;

  const _CriteriaRow({
    required this.item,
    required this.index,
    required this.bizNames,
    required this.getError,
    required this.onChanged,
  });

  @override
  State<_CriteriaRow> createState() => _CriteriaRowState();
}

class _CriteriaRowState extends State<_CriteriaRow> {
  late final TextEditingController _weightCtrl;
  late final List<TextEditingController> _scoreCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.item.weight == 0 ? '' : widget.item.weight.toString(),
    );
    _scoreCtrl = List.generate(
      3,
      (i) => TextEditingController(text: widget.item.scores[i]),
    );
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    for (final c in _scoreCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool isEven = widget.index % 2 == 0;
    return Container(
      decoration: BoxDecoration(
        color: isEven ? AppTheme.cardBg : AppTheme.divider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان + دسته + وزن در یک ردیف
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (item.category.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // وزن — badge قابل ویرایش کنار عنوان
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'وزن :',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: _weightCtrl,
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            item.weight = parsed ?? 0;
                            widget.onChanged();
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryDark,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textHint,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ردیف دوم: ۳ فیلد امتیاز
          Row(
            children: List.generate(3, (bizIndex) {
              final error = widget.getError(bizIndex);
              final hasError = error != null;
              final bizName = widget.bizNames[bizIndex].isNotEmpty
                  ? widget.bizNames[bizIndex]
                  : 'کسب‌و‌کار ${bizIndex + 1}';
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: bizIndex > 0 ? 6 : 0),
                  child: TextFormField(
                    controller: _scoreCtrl[bizIndex],
                    onChanged: (v) {
                      item.scores[bizIndex] = v;
                      widget.onChanged();
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasError ? Colors.red[700] : AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: bizName,
                      labelStyle: const TextStyle(fontSize: 10),
                      errorText: error,
                      errorStyle: const TextStyle(fontSize: 9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: hasError
                              ? Colors.red.withValues(alpha: 0.5)
                              : AppTheme.border,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 1.8,
                        ),
                      ),
                      filled: true,
                      fillColor: hasError
                          ? Colors.red.withValues(alpha: 0.06)
                          : AppTheme.cardBg,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
