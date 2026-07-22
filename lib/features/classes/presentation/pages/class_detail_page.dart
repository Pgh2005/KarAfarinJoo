import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/class_detail_header.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/student_class_detail_section.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/teacher_class_members_section.dart';

class ClassDetailPage extends ConsumerWidget {
  final ClassModel classModel;

  const ClassDetailPage({super.key, required this.classModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTeacherAsync = ref.watch(isTeacherForClassProvider(classModel.id));

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: const AppBarBuilder(title: 'جزئیات کلاس'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(isTeacherForClassProvider(classModel.id));
            ref.invalidate(teacherClassesProvider);
            ref.invalidate(studentClassesProvider);
            ref.invalidate(classMembersProvider(classModel.id));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClassDetailHeader(classModel: classModel),
              const SizedBox(height: 24),
              isTeacherAsync.when(
                data: (isTeacher) {
                  if (isTeacher) {
                    return TeacherClassMembersSection(classId: classModel.id);
                  }

                  return StudentClassDetailSection(classModel: classModel);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) =>
                    Center(child: Text('خطا در تشخیص نقش کاربر: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
