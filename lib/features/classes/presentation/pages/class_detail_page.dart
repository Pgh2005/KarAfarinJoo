import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/core/widgets/responsive_scaffold.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/class_detail_header.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/student_class_detail_section.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/class_members_section.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

class ClassDetailPage extends ConsumerWidget {
  final ClassModel classModel;

  const ClassDetailPage({super.key, required this.classModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProfessor = ref.watch(isProfessorProvider);

    return ResponsiveScaffold(
      backgroundColor: AppTheme.surface,
      appBar: const AppBarBuilder(title: 'جزئیات کلاس'),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            ref.invalidate(teacherClassesProvider);
            ref.invalidate(studentClassesProvider);
            ref.invalidate(classMembersProvider(classModel.id));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClassDetailHeader(classModel: classModel),
              const SizedBox(height: 24),
              isProfessor
                  ? ClassMembersSection(classId: classModel.id)
                  : StudentClassDetailSection(classModelId: classModel.id),
            ],
          ),
        ),
      ),
    );
  }
}
