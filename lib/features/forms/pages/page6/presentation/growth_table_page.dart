import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/utils/date_picker/persian_date_picker_sheet.dart';
import 'package:karafarini/core/utils/thousands_separator_input_formatter.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/core/utils/app_date_formatter.dart';
import 'package:karafarini/features/forms/widgets/info_hint_box.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import '../models/growth_table_model.dart';
import '../providers/growth_table_provider.dart';

class GrowthTablePage extends ConsumerStatefulWidget {
  final String classId;
  final String studentId;
  final bool isProfessor;

  const GrowthTablePage({
    super.key,
    required this.classId,
    required this.studentId,
    this.isProfessor = false,
  });

  @override
  ConsumerState<GrowthTablePage> createState() => _GrowthTablePageState();
}

class _GrowthTablePageState extends ConsumerState<GrowthTablePage> {
  bool _isSaving = false;

  Future<void> _save(GrowthTableParams params) async {
    setState(() => _isSaving = true);

    final notifier = ref.read(growthTableProvider(params).notifier);
    final success = await notifier.save();

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'اطلاعات با موفقیت ذخیره شد.'
              : 'خطا در ذخیره‌سازی اطلاعات.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog({
    required GrowthTableNotifier notifier,
    required int index,
  }) async {
    // استفاده مستقیم از context کلاس State به جای آرگومان ورودی
    final bool confirm =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'حذف دوره',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Text(
                'آیا از حذف دوره ${index + 1} اطمینان دارید؟ این عمل بلافاصله ذخیره شده و قابل بازگشت نیست.',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text(
                    'انصراف',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    'حذف شود',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;

    // حالا این گاردِ mounted به درستی context مربوط به State را تایید می‌کند و خطا رفع می‌شود.
    if (!mounted) return;
    if (!confirm) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('در حال حذف و بروزرسانی دیتابیس...'),
        duration: Duration(milliseconds: 800),
      ),
    );

    await notifier.removePeriod(index);
  }

  @override
  Widget build(BuildContext context) {
    final params = GrowthTableParams(
      studentId: widget.studentId,
      classId: widget.classId,
    );

    final state = ref.watch(growthTableProvider(params));
    final notifier = ref.read(growthTableProvider(params).notifier);
    final isEditable = !widget.isProfessor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBarBuilder(
          title: 'جدول رشد کارآفرینی',
          actions: [
            IconButton(
              tooltip: 'افزودن دوره',
              onPressed: () {
                if (!isEditable) return;
                notifier.addPeriod();

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('دوره جدید با موفقیت اضافه شد.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        ),
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'خطا در دریافت داده: $err',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          data: (periods) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const InfoHintBox(
                  text:
                      'برای هر دوره، تاریخ شروع و هدف را مشخص کنید و برای هر شاخص مقدار فعلی، هدف و نتیجه واقعی را وارد نمایید.',
                ),
                const SizedBox(height: 16),
                if (isEditable) ...[
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        notifier.addPeriod();

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('دوره جدید با موفقیت اضافه شد.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(
                          color: AppTheme.primary,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text(
                        'افزودن دوره جدید',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (periods.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text(
                      'هنوز دوره‌ای ثبت نشده است.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: periods.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _PeriodCard(
                        period: periods[index],
                        index: index,
                        enabled: isEditable,
                        notifier: notifier,
                        onDeleteTap: () => _showDeleteConfirmDialog(
                          notifier: notifier,
                          index: index,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
                if (isEditable)
                  SaveButton(
                    onSave: () => _save(params),
                    isEnabled: !_isSaving,
                    isLoading: _isSaving,
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final GrowthPeriod period;
  final int index;
  final bool enabled;
  final GrowthTableNotifier notifier;
  final VoidCallback onDeleteTap;

  const _PeriodCard({
    required this.period,
    required this.index,
    required this.enabled,
    required this.notifier,
    required this.onDeleteTap,
  });

  Map<String, List<MapEntry<int, GrowthMetricRow>>> _groupedMetrics() {
    final grouped = <String, List<MapEntry<int, GrowthMetricRow>>>{};

    for (int i = 0; i < period.metrics.length; i++) {
      final metric = period.metrics[i];
      grouped.putIfAbsent(metric.category, () => []).add(MapEntry(i, metric));
    }

    return grouped;
  }

  bool _validateAndUpdateDates(
    BuildContext context, {
    String? newStart,
    String? newTarget,
  }) {
    final start = newStart ?? period.startDate;
    final target = newTarget ?? period.targetDate;

    if (start.isNotEmpty && target.isNotEmpty) {
      final isInvalid = AppDateFormatter.isAfter(start, target);
      if (isInvalid) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا: تاریخ هدف باید بعد از تاریخ شروع باشد.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    notifier.updateDates(index, start, target);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedMetrics();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'دوره ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const Spacer(),
                if (enabled && index > 0)
                  IconButton(
                    onPressed: onDeleteTap,
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    tooltip: 'حذف این دوره',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'تاریخ شروع',
                        value: period.startDate,
                        hintText: '1405/04/01',
                        enabled: enabled,
                        onChanged: (value) =>
                            _validateAndUpdateDates(context, newStart: value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateField(
                        label: 'تاریخ هدف',
                        value: period.targetDate,
                        hintText: '1405/10/01',
                        enabled: enabled,
                        onChanged: (value) =>
                            _validateAndUpdateDates(context, newTarget: value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...grouped.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CategorySection(
                      categoryTitle: entry.key,
                      metrics: entry.value,
                      periodIndex: index,
                      enabled: enabled,
                      notifier: notifier,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatefulWidget {
  final String label;
  final String value;
  final String? hintText;
  final bool enabled;
  final bool Function(String value) onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  Future<void> _selectDate() async {
    if (!widget.enabled) return;

    final initialDate = widget.value.trim().isEmpty
        ? null
        : AppDateFormatter.parseJalaliSlash(widget.value);

    final pickedDate = await PersianDatePickerSheet.show(
      context,
      initialDate: initialDate,
    );

    if (pickedDate == null || !mounted) return;

    final formattedDate = AppDateFormatter.toJalaliSlash(pickedDate);
    final success = widget.onChanged(formattedDate);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تاریخ با موفقیت ثبت شد.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: IgnorePointer(
        child: TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          readOnly: true,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.primary,
              size: 18,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String categoryTitle;
  final List<MapEntry<int, GrowthMetricRow>> metrics;
  final int periodIndex;
  final bool enabled;
  final GrowthTableNotifier notifier;

  const _CategorySection({
    required this.categoryTitle,
    required this.metrics,
    required this.periodIndex,
    required this.enabled,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: metrics
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _MetricRow(
                        metric: entry.value,
                        metricIndex: entry.key,
                        periodIndex: periodIndex,
                        enabled: enabled,
                        notifier: notifier,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final GrowthMetricRow metric;
  final int metricIndex;
  final int periodIndex;
  final bool enabled;
  final GrowthTableNotifier notifier;

  const _MetricRow({
    required this.metric,
    required this.metricIndex,
    required this.periodIndex,
    required this.enabled,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  metric.unit,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
            ],
          ),

          if (metric.description.isNotEmpty) ...[
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
                      metric.description,
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
            children: [
              Expanded(
                child: _SmallField(
                  label: 'مقدار فعلی',
                  value: metric.currentValue,
                  enabled: enabled,
                  onChanged: (value) => notifier.updateMetric(
                    periodIndex,
                    metricIndex,
                    'current',
                    value,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SmallField(
                  label: 'هدف',
                  value: metric.target,
                  enabled: enabled,
                  onChanged: (value) => notifier.updateMetric(
                    periodIndex,
                    metricIndex,
                    'target',
                    value,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SmallField(
                  label: 'نتیجه',
                  value: metric.result,
                  enabled: enabled,
                  onChanged: (value) => notifier.updateMetric(
                    periodIndex,
                    metricIndex,
                    'result',
                    value,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallField extends StatefulWidget {
  final String label;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _SmallField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<_SmallField> createState() => _SmallFieldState();
}

class _SmallFieldState extends State<_SmallField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant _SmallField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final formatted = _formatValue(widget.value);
    if (_controller.text != formatted) {
      _controller.text = formatted;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      onChanged: (value) {
        widget.onChanged(value.replaceAll(',', ''));
      },
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorInputFormatter(),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(fontSize: 9.5),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
        ),
        filled: true,
        fillColor: AppTheme.divider,
      ),
    );
  }

  String _formatValue(String value) {
    final raw = value.replaceAll(',', '').trim();
    if (raw.isEmpty) return '';
    if (!RegExp(r'^\d+$').hasMatch(raw)) return value;

    final chars = raw.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    return buffer.toString().split('').reversed.join();
  }
}
