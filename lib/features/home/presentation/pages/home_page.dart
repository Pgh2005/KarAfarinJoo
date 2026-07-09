import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/theme/app_Theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/profile/models/profile.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentSessionProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: const AppBarBuilder(title: 'خانه'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'خطا در دریافت اطلاعات کاربر:\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('کاربر یافت نشد.')));
        }

        final isProfessor = profile.role == UserRole.professor;

        final classesAsync = isProfessor
            ? ref.watch(teacherClassesProvider)
            : ref.watch(studentClassesProvider);

        return Scaffold(
          appBar: AppBarBuilder(
            title: 'کلاس‌های من',
            leading: IconButton(
              icon: const Icon(Icons.account_circle_outlined, size: 28),
              onPressed: () => context.pushNamed('profile'),
            ),
          ),
          body: classesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'خطا در دریافت کلاس‌ها:\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (classes) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentSessionProfileProvider);
                if (isProfessor) {
                  ref.invalidate(teacherClassesProvider);
                  await ref.read(teacherClassesProvider.future);
                } else {
                  ref.invalidate(studentClassesProvider);
                  await ref.read(studentClassesProvider.future);
                }
              },
              child: _ClassListView(classes: classes, isProfessor: isProfessor),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primary,
            onPressed: () async {
              if (isProfessor) {
                final result = await context.pushNamed('create-class');
                if (result == true) {
                  ref.invalidate(teacherClassesProvider);
                }
              } else {
                await context.pushNamed('join-class');
              }
            },
            child: Icon(
              isProfessor ? Icons.add : Icons.group_add,
              color: AppTheme.surface,
            ),
          ),
        );
      },
    );
  }
}

class _ClassListView extends StatelessWidget {
  final List<ClassModel> classes;
  final bool isProfessor;

  const _ClassListView({required this.classes, required this.isProfessor});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Text(
                isProfessor
                    ? 'هنوز کلاسی ایجاد نکرده‌اید'
                    : 'هنوز عضو هیچ کلاسی نشده‌اید',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = classes[index];

        final details = <String>[
          if (item.courseCode.trim().isNotEmpty) 'کد درس: ${item.courseCode}',
          if (item.semester.trim().isNotEmpty) 'ترم: ${item.semester}',
        ];

        return Card(
          child: ListTile(
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: details.isEmpty ? null : Text(details.join(' | ')),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              // TODO: جزئیات کلاس
            },
          ),
        );
      },
    );
  }
}
