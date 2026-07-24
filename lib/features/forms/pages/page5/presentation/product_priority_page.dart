import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/pages/page1/providers/personal_info_provider.dart';
import 'package:karafarini/features/forms/widgets/info_hint_box.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/forms/widgets/score_card.dart';
import 'package:karafarini/features/forms/widgets/section_card.dart';
import '../models/product_priority_model.dart';
import '../providers/product_priority_provider.dart';

class ProductPriorityPage extends ConsumerStatefulWidget {
  final String classId;
  final String studentId;
  final bool isProfessor;

  const ProductPriorityPage({
    super.key,
    required this.classId,
    required this.studentId,
    this.isProfessor = false,
  });

  @override
  ConsumerState<ProductPriorityPage> createState() =>
      _ProductPriorityPageState();
}

class _ProductPriorityPageState extends ConsumerState<ProductPriorityPage> {
  late final List<TextEditingController> _productNameControllers;
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _productNameControllers = List.generate(4, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _productNameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncData(ProductPriorityModel model) {
    if (_isInitialized) return;
    for (int i = 0; i < 4; i++) {
      _productNameControllers[i].text = model.productNames[i];
    }
    _isInitialized = true;
  }

  double _parseScore(String value) {
    final raw = value.replaceAll(',', '').trim();
    return double.tryParse(raw) ?? 0.0;
  }

  List<double> _calcTotals(ProductPriorityModel model) {
    return List.generate(4, (productIndex) {
      return model.criteria.fold<double>(0.0, (sum, item) {
        final score = _parseScore(item.scores[productIndex]);
        final weight = item.weight.toDouble();
        return sum + score.clamp(0.0, weight);
      });
    });
  }

  double _maxScore(ProductPriorityModel model) {
    return model.criteria.fold<double>(0.0, (sum, item) {
      return sum + item.weight.toDouble();
    });
  }

  String? _fieldError(ProductCriterionModel item, int productIndex) {
    final raw = item.scores[productIndex].replaceAll(',', '').trim();
    final score = double.tryParse(raw);

    if (score == null && raw.isNotEmpty) {
      return 'عدد وارد کنید';
    }

    final weight = item.weight.toDouble();
    if (score != null && score > weight) {
      return 'بیشتر از وزن ($weight)';
    }

    final others = List.generate(4, (i) => i)
        .where((i) => i != productIndex)
        .map((i) => item.scores[i].replaceAll(',', '').trim())
        .where((v) => v.isNotEmpty)
        .map((v) => double.tryParse(v))
        .whereType<double>();

    if (score != null && others.contains(score)) {
      return 'تکراری';
    }

    return null;
  }

  Map<String, List<MapEntry<int, ProductCriterionModel>>> _groupCriteria(
    List<ProductCriterionModel> criteria,
  ) {
    final groups = <String, List<MapEntry<int, ProductCriterionModel>>>{};

    for (int i = 0; i < criteria.length; i++) {
      final category = criteria[i].category;
      groups.putIfAbsent(category, () => []);
      groups[category]!.add(MapEntry(i, criteria[i]));
    }

    return groups;
  }

  Future<void> _save(FormParams params) async {
    setState(() => _isSaving = true);

    final notifier = ref.read(productPriorityNotifierProvider(params).notifier);

    notifier.updateState(
      (model) => model.copyWith(
        productNames: _productNameControllers
            .map((c) => c.text.trim())
            .toList(),
      ),
    );

    final success = await notifier.saveData();

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'اطلاعات با موفقیت ذخیره شد.' : 'ذخیره سازی ناموفق بود.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = FormParams(
      classId: widget.classId,
      studentId: widget.studentId,
    );

    final asyncState = ref.watch(productPriorityNotifierProvider(params));
    final isEditable = !widget.isProfessor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'اولویت بندی محصولات'),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطا: $e')),
          data: (model) {
            _syncData(model);

            final totals = _calcTotals(model);
            final maxScore = _maxScore(model);
            final grouped = _groupCriteria(model.criteria);

            int winnerIndex = 0;
            for (int i = 1; i < 4; i++) {
              if (totals[i] > totals[winnerIndex]) {
                winnerIndex = i;
              }
            }
            final anyScore = totals.any((t) => t > 0);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'نام محصولات',
                    children: [
                      const Text(
                        'ابتدا نام ۴ محصول خود را وارد کنید',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(
                        4,
                        (i) => Padding(
                          padding: EdgeInsets.only(bottom: i < 3 ? 10 : 0),
                          child: TextField(
                            controller: _productNameControllers[i],
                            enabled: isEditable,
                            decoration: InputDecoration(
                              labelText: 'محصول ${i + 1}',
                              prefixIcon: Icon(
                                Icons.shopping_bag_outlined,
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
                        'امتیاز هر محصول نباید از وزن آن معیار بیشتر باشد و نمی توانند با هم یکسان باشند.',
                  ),
                  const SizedBox(height: 16),
                  ...grouped.entries.map(
                    (group) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 4),
                          child: Text(
                            group.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ...group.value.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ProductCriteriaRow(
                              item: entry.value,
                              index: entry.key,
                              productNames: _productNameControllers
                                  .map((c) => c.text)
                                  .toList(),
                              enabled: isEditable,
                              getError: (productIndex) =>
                                  _fieldError(entry.value, productIndex),
                              onChanged: () => setState(() {}),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'نتیجه امتیازات',
                    children: [
                      ...List.generate(4, (i) {
                        final isWinner = anyScore && i == winnerIndex;
                        final percent = maxScore > 0
                            ? totals[i] / maxScore * 100
                            : 0.0;
                        final productName =
                            _productNameControllers[i].text.trim().isNotEmpty
                            ? _productNameControllers[i].text.trim()
                            : 'محصول ${i + 1}';

                        return Padding(
                          padding: EdgeInsets.only(bottom: i < 3 ? 12 : 0),
                          child: ScoreCard(
                            name: productName,
                            score: totals[i],
                            percent: percent,
                            maxScore: maxScore,
                            isWinner: isWinner,
                            winnerLabel: 'این محصول بالاترین امتیاز را دارد',
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (isEditable)
                    SaveButton(
                      onSave: () => _save(params),
                      isLoading: _isSaving,
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

class _ProductCriteriaRow extends StatefulWidget {
  final ProductCriterionModel item;
  final int index;
  final List<String> productNames;
  final bool enabled;
  final String? Function(int productIndex) getError;
  final VoidCallback onChanged;

  const _ProductCriteriaRow({
    required this.item,
    required this.index,
    required this.productNames,
    required this.enabled,
    required this.getError,
    required this.onChanged,
  });

  @override
  State<_ProductCriteriaRow> createState() => _ProductCriteriaRowState();
}

class _ProductCriteriaRowState extends State<_ProductCriteriaRow> {
  late final TextEditingController _weightCtrl;
  late final List<TextEditingController> _scoreCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.item.weight == 0 ? '' : widget.item.weight.toString(),
    );
    _scoreCtrl = List.generate(
      4,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
                    horizontal: 6,
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
                          enabled: widget.enabled,
                          onChanged: (v) {
                            widget.item.weight = int.tryParse(v) ?? 0;
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
          const SizedBox(height: 10),
          Row(
            children: [_buildScoreField(0, false), _buildScoreField(1, true)],
          ),
          const SizedBox(height: 8),
          Row(
            children: [_buildScoreField(2, false), _buildScoreField(3, true)],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreField(int productIndex, bool hasRightPadding) {
    final error = widget.getError(productIndex);
    final hasError = error != null;
    final productName = widget.productNames[productIndex].trim().isNotEmpty
        ? widget.productNames[productIndex].trim()
        : 'محصول ${productIndex + 1}';

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: hasRightPadding ? 6 : 0),
        child: TextFormField(
          controller: _scoreCtrl[productIndex],
          enabled: widget.enabled,
          onChanged: (v) {
            widget.item.scores[productIndex] = v;
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
            labelText: productName,
            labelStyle: const TextStyle(fontSize: 10),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
            ),
            filled: true,
            fillColor: hasError
                ? Colors.red.withValues(alpha: 0.06)
                : AppTheme.cardBg,
          ),
        ),
      ),
    );
  }
}
