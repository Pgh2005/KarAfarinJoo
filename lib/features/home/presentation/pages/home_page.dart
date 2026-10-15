import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/theme/app_Theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/core/widgets/responsive_scaffold.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/classes/presentation/widgets/invite/enter_invite_code_dialog.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/classes/providers/invite_provider.dart';
import 'package:karafarini/features/classes/models/join_request_model.dart';
import 'package:karafarini/features/profile/models/profile.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshProviders());
  }

  void _refreshProviders() {
    ref.invalidate(studentClassesProvider);
    ref.invalidate(teacherClassesProvider);
    ref.invalidate(pendingInviteRequestsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentSessionProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: const AppBarBuilder(title: 'خانه'),
        body: Center(
          child: Text(
            'خطا در دریافت اطلاعات کاربر:\n$e',
            textAlign: TextAlign.center,
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

        return ResponsiveScaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBarBuilder(
            title: 'کلاس‌های من',
            leading: IconButton(
              icon: const Icon(Icons.account_circle_outlined, size: 28),
              onPressed: () => context.pushNamed('profile'),
            ),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final count = ref
                      .watch(pendingInviteRequestsProvider)
                      .maybeWhen(
                        data: (r) => r
                            .where(
                              (it) =>
                                  it.request.status ==
                                  JoinRequestStatus.pending,
                            )
                            .length,
                        orElse: () => 0,
                      );
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () async {
                          await context.pushNamed('invite-requests');
                          ref.invalidate(pendingInviteRequestsProvider);
                          ref.invalidate(teacherClassesProvider);
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: classesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'خطا در دریافت کلاس‌ها:\n$e',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (classes) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentSessionProfileProvider);
                if (isProfessor) {
                  ref.invalidate(teacherClassesProvider);
                  ref.invalidate(pendingInviteRequestsProvider);
                  await ref.read(teacherClassesProvider.future);
                } else {
                  ref.invalidate(studentClassesProvider);
                  await ref.read(studentClassesProvider.future);
                }
              },
              child: _ClassListView(
                classes: classes,
                isProfessor: isProfessor,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.primary,
            elevation: 4,
            onPressed: () async {
              if (isProfessor) {
                final result = await context.pushNamed('create-class');
                if (result == true) ref.invalidate(teacherClassesProvider);
              } else {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const EnterInviteCodeDialog(),
                );
                if (result == true) ref.invalidate(studentClassesProvider);
              }
            },
            icon: Icon(
              isProfessor ? Icons.add : Icons.group_add,
              color: Colors.white,
            ),
            label: Text(
              isProfessor ? 'کلاس جدید' : 'عضویت در کلاس',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.startFloat,
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
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.1),
                        AppTheme.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    size: 40,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isProfessor
                      ? 'هنوز کلاسی ایجاد نکرده‌اید'
                      : 'هنوز عضو هیچ کلاسی نشده‌اید',
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    isProfessor
                        ? 'با دکمه پایین صفحه اولین کلاس خود را بسازید'
                        : 'با دکمه پایین صفحه وارد کلاس مورد نظر شوید',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textHint,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: classes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = classes[index];
        final details = <String>[
          if (item.courseCode.trim().isNotEmpty) item.courseCode,
          if (item.semester.trim().isNotEmpty) item.semester,
        ];
        final initials = item.title.trim().isNotEmpty
            ? item.title.trim()[0]
            : '?';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pushNamed('class-detail', extra: item),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar with gradient
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primaryDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (details.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: details
                                  .map(
                                    (d) => _Chip(
                                      label: d,
                                      color: AppTheme.primary,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
