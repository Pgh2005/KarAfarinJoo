import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/pages/page1/providers/personal_info_provider.dart';
import 'package:karafarini/features/forms/widgets/form_field_builder.dart';
import 'package:karafarini/features/forms/widgets/form_progress.dart';
import 'package:karafarini/features/forms/widgets/progress_bar_widget.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/forms/widgets/section_card.dart';
import '../providers/values_provider.dart';
import '../models/values_model.dart';

class ValuesPage extends ConsumerStatefulWidget {
  final String classId;
  final String studentId;
  final bool isProfessor;

  const ValuesPage({
    super.key,
    required this.classId,
    required this.studentId,
    this.isProfessor = false,
  });

  @override
  ConsumerState<ValuesPage> createState() => _ValuesPageState();
}

class _ValuesPageState extends ConsumerState<ValuesPage> {
  late final List<TextEditingController> _controllers;
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(10, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers(ValuesModel model) {
    if (_isInitialized) return;
    for (int i = 0; i < 10; i++) {
      if (i < model.valuesList.length) {
        _controllers[i].text = model.valuesList[i];
      }
    }
    _isInitialized = true;
  }

  Future<void> _handleSave(ValuesNotifier notifier) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final newList = _controllers.map((c) => c.text.trim()).toList();
    notifier.updateState((m) => m.copyWith(valuesList: newList));

    final success = await notifier.saveData();

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'ارزش‌ها با موفقیت ذخیره شدند' : 'خطا در ذخیره‌سازی',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = FormParams(
      classId: widget.classId,
      studentId: widget.studentId,
    );
    final asyncState = ref.watch(valuesNotifierProvider(params));
    final isEditable = !widget.isProfessor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: '۱۰ ارزش مهم شما'),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطا: $err')),
          data: (model) {
            _syncControllers(model);

            final progress = model.progress;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Progress Bar ──
                  FormProgressBar(
                    percent: progress.percent,
                    showLabel: true,
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'لیست ارزش‌های فردی',
                    icon: Icons.format_list_numbered_rtl_rounded,
                    children: [
                      const Text(
                        'ده مورد از مهم‌ترین ارزش‌های زندگی و کاری خود را به ترتیب اولویت بنویسید.',
                        style: TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(10, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FormBuilder.buildTextField(
                            'ارزش شماره ${index + 1}',
                            '',
                            null,
                            controller: _controllers[index],
                            enabled: isEditable,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (isEditable)
                    SaveButton(
                      onSave: () => _handleSave(
                        ref.read(valuesNotifierProvider(params).notifier),
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
