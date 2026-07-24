import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/pages/page1/providers/personal_info_provider.dart';
import 'package:karafarini/features/forms/widgets/info_hint_box.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/forms/widgets/score_card.dart';
import 'package:karafarini/features/forms/widgets/section_card.dart';
import '../models/business_selection_model.dart';
import '../providers/business_selection_provider.dart';

class BusinessSelectionPage extends ConsumerStatefulWidget {
  final String classId;
  final String studentId;
  final bool isProfessor;

  const BusinessSelectionPage({
    super.key,
    required this.classId,
    required this.studentId,
    this.isProfessor = false,
  });

  @override
  ConsumerState<BusinessSelectionPage> createState() =>
      _BusinessSelectionPageState();
}

class _BusinessSelectionPageState extends ConsumerState<BusinessSelectionPage> {
  late final List<TextEditingController> _bizNameControllers;
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bizNameControllers = List.generate(3, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _bizNameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncData(BusinessSelectionModel model) {
    if (_isInitialized) return;
    for (int i = 0; i < 3; i++) {
      _bizNameControllers[i].text = model.bizNames[i];
    }
    _isInitialized = true;
  }

  List<double> _calcTotals(BusinessSelectionModel model) {
    return List.generate(3, (bizIndex) {
      return model.criteria.fold<double>(0.0, (sum, item) {
        final raw = item.scores[bizIndex].replaceAll(',', '');
        final score = double.tryParse(raw) ?? 0.0;
        final weight = item.weight.toDouble();
        return sum + score.clamp(0.0, weight);
      });
    });
  }

  double _maxScore(BusinessSelectionModel model) {
    return model.criteria.fold<double>(0.0, (sum, item) {
      return sum + item.weight.toDouble();
    });
  }

  String? _fieldError(BusinessCriterionModel item, int bizIndex) {
    final raw = item.scores[bizIndex].replaceAll(',', '');
    final score = double.tryParse(raw);
    if (score == null && raw.isNotEmpty) return 'عدد وارد کنید';

    final weight = item.weight.toDouble();
    if (score != null && score > weight) return 'بیشتر از وزن ($weight)';

    final others = List.generate(3, (i) => i)
        .where((i) => i != bizIndex)
        .map((i) => item.scores[i].replaceAll(',', ''))
        .where((v) => v.isNotEmpty)
        .map((v) => double.tryParse(v))
        .whereType<double>();

    if (score != null && others.contains(score)) return 'تکراری';
    return null;
  }

  Future<void> _handleSave(
    BusinessSelectionNotifier notifier,
    BusinessSelectionModel currentModel,
  ) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final bizNames = _bizNameControllers.map((c) => c.text.trim()).toList();
    final updatedModel = currentModel.copyWith(bizNames: bizNames);

    notifier.updateState((_) => updatedModel);
    final success = await notifier.saveData();

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'اطلاعات با موفقیت ذخیره شدند'
              : 'خطا در ذخیره‌سازی اطلاعات',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // متد کمکی برای گروه‌بندی معیارها با حفظ ترتیب اصلی
  Map<String, List<MapEntry<int, BusinessCriterionModel>>> _groupCriteria(
    List<BusinessCriterionModel> criteria,
  ) {
    final Map<String, List<MapEntry<int, BusinessCriterionModel>>> groups = {};
    for (int i = 0; i < criteria.length; i++) {
      final item = criteria[i];
      final cat = item.category.isNotEmpty ? item.category : 'سایر معیارها';
      groups.putIfAbsent(cat, () => []).add(MapEntry(i, item));
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final params = FormParams(
      classId: widget.classId,
      studentId: widget.studentId,
    );
    final asyncState = ref.watch(businessSelectionNotifierProvider(params));
    final isEditable = !widget.isProfessor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'انتخاب کسب‌و‌کار'),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) =>
              Center(child: Text('خطا در بارگذاری اطلاعات: $err')),
          data: (model) {
            _syncData(model);
            final totals = _calcTotals(model);
            final maxScore = _maxScore(model);

            int winnerIndex = 0;
            for (int i = 1; i < 3; i++) {
              if (totals[i] > totals[winnerIndex]) {
                winnerIndex = i;
              }
            }

            final anyScore = totals.any((t) => t > 0);
            final grouped = _groupCriteria(model.criteria);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            enabled: isEditable,
                            decoration: InputDecoration(
                              labelText: 'کسب‌و‌کار ${i + 1}',
                              prefixIcon: const Icon(
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
                  const InfoHintBox(
                    text:
                        'امتیاز هر کسب‌و‌کار نباید از وزن آن معیار بیشتر باشد و نمی‌توانند در یک ردیف با هم یکسان باشند.',
                  ),

                  const SizedBox(height: 15),

                  // نمایش گروه‌بندی شده معیارها
                  ...grouped.entries.map((group) {
                    final categoryName = group.key;
                    final entries = group.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 15,
                            right: 4,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 15),
                          itemBuilder: (context, idx) {
                            final entry = entries[idx];
                            final globalIndex = entry.key;
                            final item = entry.value;

                            return _CriteriaRow(
                              item: item,
                              index: globalIndex,
                              bizNames: _bizNameControllers
                                  .map((c) => c.text)
                                  .toList(),
                              getError: (bizIndex) =>
                                  _fieldError(item, bizIndex),
                              enabled: isEditable,
                              onChanged: () => setState(() {}),
                            );
                          },
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 10),
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
                            percent: percent,
                            maxScore: maxScore,
                            isWinner: isWinner,
                            winnerLabel:
                                'این کسب‌و‌کار بالاترین امتیاز را دارد',
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (isEditable)
                    SaveButton(
                      onSave: () => _handleSave(
                        ref.read(
                          businessSelectionNotifierProvider(params).notifier,
                        ),
                        model,
                      ),
                      isLoading: _isSaving,
                      isEnabled: !_isSaving,
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CriteriaRow extends StatefulWidget {
  final BusinessCriterionModel item;
  final int index;
  final List<String> bizNames;
  final String? Function(int bizIndex) getError;
  final VoidCallback onChanged;
  final bool enabled;

  const _CriteriaRow({
    required this.item,
    required this.index,
    required this.bizNames,
    required this.getError,
    required this.onChanged,
    required this.enabled,
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
    final isEven = widget.index % 2 == 0;

    return Container(
      decoration: BoxDecoration(
        color: isEven ? AppTheme.cardBg : AppTheme.divider,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'وزن:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 34,
                      child: TextFormField(
                        controller: _weightCtrl,
                        enabled: widget.enabled,
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
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                          hintText: '0',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
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
                    enabled: widget.enabled,
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
