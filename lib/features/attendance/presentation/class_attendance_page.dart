import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/attendance/models/attendance_models.dart';
import 'package:karafarini/features/attendance/providers/attendance_provider.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassAttendancePage extends ConsumerStatefulWidget {
  final ClassModel classModel;

  const ClassAttendancePage({super.key, required this.classModel});

  @override
  ConsumerState<ClassAttendancePage> createState() =>
      _ClassAttendancePageState();
}

class _ClassAttendancePageState extends ConsumerState<ClassAttendancePage> {
  bool _isSaving = false;

  Future<void> _refresh() async {
    ref.invalidate(attendanceOverviewProvider(widget.classModel.id));
    ref.invalidate(attendanceMembersProvider(widget.classModel.id));
    await ref.read(attendanceOverviewProvider(widget.classModel.id).future);
  }

  Future<void> _perform(Future<void> Function() action) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await action();
      if (!mounted) return;
      await _refresh();
    } on PostgrestException catch (error) {
      _showMessage('عملیات ناموفق بود: ${error.message}');
    } on Exception catch (error) {
      _showMessage('عملیات ناموفق بود: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editSchedule({AttendanceSchedule? schedule}) async {
    final saved = await showModalBottomSheet<_ScheduleDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ScheduleEditor(schedule: schedule),
    );
    if (saved == null || !mounted) return;

    await _perform(
      () => ref
          .read(attendanceServiceProvider)
          .saveSchedule(
            classId: widget.classModel.id,
            weekday: saved.weekday,
            startsAt: saved.startsAt,
            endsAt: saved.endsAt,
            isActive: saved.isActive,
          ),
    );
  }

  Future<void> _review(AttendanceRecord record, String status) async {
    await _perform(
      () => ref
          .read(attendanceServiceProvider)
          .reviewAttendance(recordId: record.id, status: status),
    );
  }

  Future<void> _setAttendance({
    required AttendanceSession session,
    required ClassMemberModel member,
    required String status,
  }) async {
    await _perform(
      () => ref
          .read(attendanceServiceProvider)
          .setAttendance(
            sessionId: session.id,
            studentId: member.studentId,
            status: status,
          ),
    );
  }

  Future<void> _toggleScheduleActive(AttendanceSchedule schedule) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          schedule.isActive ? 'حذف روز از برنامه' : 'بازگرداندن روز به برنامه',
        ),
        content: Text(
          schedule.isActive
              ? 'این روز از برنامهٔ هفتگی آینده غیرفعال می‌شود. اطلاعات جلسات گذشته حذف نخواهد شد.'
              : 'این روز دوباره در برنامهٔ هفتگی فعال می‌شود.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(schedule.isActive ? 'غیرفعال‌کردن' : 'فعال‌کردن'),
          ),
        ],
      ),
    );
    if (shouldContinue != true || !mounted) return;

    await _perform(
      () => ref
          .read(attendanceServiceProvider)
          .saveSchedule(
            classId: schedule.classId,
            weekday: schedule.weekday,
            startsAt: schedule.startsAt,
            endsAt: schedule.endsAt,
            isActive: !schedule.isActive,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isProfessor = ref.watch(isProfessorProvider);
    final isOwner =
        ref.watch(currentUserIdProvider) == widget.classModel.teacherId;
    final userId = ref.watch(currentUserIdProvider);

    if (isProfessor && !isOwner) {
      return const Scaffold(
        appBar: AppBarBuilder(title: 'حضور و غیاب'),
        body: Center(
          child: Text('فقط استاد این کلاس به حضور و غیاب دسترسی دارد.'),
        ),
      );
    }

    final overviewAsync = ref.watch(
      attendanceOverviewProvider(widget.classModel.id),
    );
    final membersAsync = isProfessor
        ? ref.watch(attendanceMembersProvider(widget.classModel.id))
        : null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'حضور و غیاب'),
        body: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _AttendanceLoadError(
            message: 'بارگذاری حضور و غیاب ناموفق بود: $error',
            onRetry: _refresh,
          ),
          data: (overview) => RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ClassAttendanceHeader(className: widget.classModel.title),
                const SizedBox(height: 16),
                _ScheduleSection(
                  schedules: isProfessor
                      ? overview.schedules
                      : overview.schedules
                            .where((schedule) => schedule.isActive)
                            .toList(),
                  canEdit: isProfessor,
                  onAdd: isProfessor ? () => _editSchedule() : null,
                  onEdit: isProfessor
                      ? (schedule) => _editSchedule(schedule: schedule)
                      : null,
                  onToggleActive: isProfessor ? _toggleScheduleActive : null,
                ),
                const SizedBox(height: 16),
                _TodaySessionCard(
                  session: overview.todaySession,
                  isProfessor: isProfessor,
                  records: overview.records,
                  studentId: userId,
                  studentAttendanceScore: overview.studentAttendanceDates.length
                      .toDouble(),
                  saving: _isSaving,
                  onRequest: overview.todaySession == null
                      ? null
                      : () => _perform(
                          () => ref
                              .read(attendanceServiceProvider)
                              .requestAttendance(overview.todaySession!.id),
                        ),
                ),
                if (isProfessor) ...[
                  const SizedBox(height: 16),
                  membersAsync!.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => _AttendanceLoadError(
                      message: 'دریافت فهرست دانشجویان ناموفق بود: $error',
                      onRetry: () async {
                        ref.invalidate(
                          attendanceMembersProvider(widget.classModel.id),
                        );
                        await ref.read(
                          attendanceMembersProvider(
                            widget.classModel.id,
                          ).future,
                        );
                      },
                    ),
                    data: (members) => _TeacherAttendanceList(
                      members: members,
                      records: overview.records,
                      session: overview.todaySession,
                      saving: _isSaving,
                      onReview: _review,
                      onSetAttendance: overview.todaySession == null
                          ? null
                          : (member, status) => _setAttendance(
                              session: overview.todaySession!,
                              member: member,
                              status: status,
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassAttendanceHeader extends StatelessWidget {
  final String className;

  const _ClassAttendanceHeader({required this.className});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.primaryLight,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primary,
          child: Icon(Icons.fact_check_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            className,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ScheduleSection extends StatelessWidget {
  final List<AttendanceSchedule> schedules;
  final bool canEdit;
  final VoidCallback? onAdd;
  final ValueChanged<AttendanceSchedule>? onEdit;
  final ValueChanged<AttendanceSchedule>? onToggleActive;

  const _ScheduleSection({
    required this.schedules,
    required this.canEdit,
    required this.onAdd,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...schedules]
      ..sort((first, second) => first.weekday.compareTo(second.weekday));

    return _AttendanceCard(
      title: 'برنامهٔ هفتگی',
      icon: Icons.calendar_month_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'هنوز روز و ساعت کلاسی تعریف نشده است.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          else
            for (final schedule in sorted)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_weekdayName(schedule.weekday)),
                subtitle: Text(
                  '${_shortTime(schedule.startsAt)} تا ${_shortTime(schedule.endsAt)}'
                  '${schedule.isActive ? '' : ' • غیرفعال'}',
                ),
                trailing: canEdit
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'ویرایش ${_weekdayName(schedule.weekday)}',
                            onPressed: () => onEdit!(schedule),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: schedule.isActive
                                ? 'حذف از برنامهٔ هفتگی'
                                : 'بازگرداندن به برنامهٔ هفتگی',
                            onPressed: () => onToggleActive!(schedule),
                            icon: Icon(
                              schedule.isActive
                                  ? Icons.event_busy_outlined
                                  : Icons.restore_outlined,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
          if (canEdit) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('افزودن یا ویرایش روز'),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodaySessionCard extends StatelessWidget {
  final AttendanceSession? session;
  final bool isProfessor;
  final List<AttendanceRecord> records;
  final String? studentId;
  final double studentAttendanceScore;
  final bool saving;
  final VoidCallback? onRequest;

  const _TodaySessionCard({
    required this.session,
    required this.isProfessor,
    required this.records,
    required this.studentId,
    required this.studentAttendanceScore,
    required this.saving,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final approvedCount = records
        .where((record) => record.status == 'approved')
        .length;
    final ownRecord = records
        .where((record) => record.studentId == studentId)
        .firstOrNull;

    return _AttendanceCard(
      title: 'جلسهٔ امروز',
      icon: Icons.today_outlined,
      child: session == null
          ? const Text(
              'برای امروز جلسه‌ای در برنامه ثبت نشده است.',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_shortTime(_timeString(session!.startsAt))} تا '
                  '${_shortTime(_timeString(session!.endsAt))}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (isProfessor)
                  _ScoreBox(
                    label: 'حضورهای تأییدشده',
                    value: '$approvedCount نفر',
                    detail: 'هر تأیید یک امتیاز مشارکت ثبت می‌کند.',
                  )
                else ...[
                  _ScoreBox(
                    label: 'امتیاز حضور شما',
                    value: _formatPoints(studentAttendanceScore),
                    detail: 'مجموع امتیاز حضورهای تأییدشده در این کلاس',
                  ),
                  const SizedBox(height: 12),
                  if (ownRecord != null)
                    _StatusLabel(status: ownRecord.status)
                  else if (session!.isRequestOpen)
                    FilledButton.icon(
                      onPressed: saving ? null : onRequest,
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.how_to_reg_outlined),
                      label: const Text('ثبت درخواست حضور'),
                    )
                  else
                    const Text(
                      'درخواست حضور از ۱۵ دقیقه مانده به شروع کلاس تا پایان آن فعال است.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

class _TeacherAttendanceList extends StatelessWidget {
  final List<ClassMemberModel> members;
  final List<AttendanceRecord> records;
  final AttendanceSession? session;
  final bool saving;
  final Future<void> Function(AttendanceRecord, String) onReview;
  final Future<void> Function(ClassMemberModel, String)? onSetAttendance;

  const _TeacherAttendanceList({
    required this.members,
    required this.records,
    required this.session,
    required this.saving,
    required this.onReview,
    required this.onSetAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final recordByStudent = {
      for (final record in records) record.studentId: record,
    };
    final pendingMembers = members
        .where(
          (member) => recordByStudent[member.studentId]?.status == 'pending',
        )
        .toList();
    final approvedMembers = members
        .where(
          (member) => recordByStudent[member.studentId]?.status == 'approved',
        )
        .toList();
    final unresolvedMembers = members
        .where(
          (member) =>
              recordByStudent[member.studentId]?.status != 'pending' &&
              recordByStudent[member.studentId]?.status != 'approved',
        )
        .toList();
    return _AttendanceCard(
      title: 'وضعیت دانشجویان',
      icon: Icons.people_alt_outlined,
      trailing: session != null
          ? Text(
              '${approvedMembers.length} تأیید • ${pendingMembers.length} درخواست',
            )
          : null,
      child: session == null
          ? const Text(
              'پس از تعریف برنامه برای امروز، فهرست حضور این جلسه نمایش داده می‌شود.',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          : members.isEmpty
          ? const Text(
              'هنوز دانشجویی عضو این کلاس نیست.',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          : Column(
              children: [
                _AttendanceGroup(
                  title: 'درخواست‌های در انتظار',
                  count: pendingMembers.length,
                  icon: Icons.mark_email_unread_outlined,
                  initiallyExpanded: pendingMembers.isNotEmpty,
                  children: [
                    for (final member in pendingMembers)
                      _StudentAttendanceTile(
                        member: member,
                        record: recordByStudent[member.studentId],
                        session: session!,
                        saving: saving,
                        onReview: onReview,
                        onSetAttendance: onSetAttendance,
                      ),
                  ],
                ),
                _AttendanceGroup(
                  title: 'حضورهای تأییدشده',
                  count: approvedMembers.length,
                  icon: Icons.verified_outlined,
                  children: [
                    for (final member in approvedMembers)
                      _StudentAttendanceTile(
                        member: member,
                        record: recordByStudent[member.studentId],
                        session: session!,
                        saving: saving,
                        onReview: onReview,
                        onSetAttendance: onSetAttendance,
                      ),
                  ],
                ),
                _AttendanceGroup(
                  title: session!.isEnded
                      ? 'غایب / بدون درخواست'
                      : 'بدون درخواست',
                  count: unresolvedMembers.length,
                  icon: session!.isEnded
                      ? Icons.person_off_outlined
                      : Icons.person_outline,
                  children: [
                    for (final member in unresolvedMembers)
                      _StudentAttendanceTile(
                        member: member,
                        record: recordByStudent[member.studentId],
                        session: session!,
                        saving: saving,
                        onReview: onReview,
                        onSetAttendance: onSetAttendance,
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _AttendanceGroup extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _AttendanceGroup({
    required this.title,
    required this.count,
    required this.icon,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: EdgeInsets.zero,
    initiallyExpanded: initiallyExpanded,
    leading: Icon(icon, color: AppTheme.primary),
    title: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text('$count', style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    ),
    children: children.isEmpty
        ? [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'موردی وجود ندارد.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ]
        : children,
  );
}

class _StudentAttendanceTile extends StatelessWidget {
  final ClassMemberModel member;
  final AttendanceRecord? record;
  final AttendanceSession session;
  final bool saving;
  final Future<void> Function(AttendanceRecord, String) onReview;
  final Future<void> Function(ClassMemberModel, String)? onSetAttendance;

  const _StudentAttendanceTile({
    required this.member,
    required this.record,
    required this.session,
    required this.saving,
    required this.onReview,
    required this.onSetAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final name = member.studentName ?? 'دانشجو';
    final number = member.studentNumber ?? 'بدون شمارهٔ دانشجویی';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProfileAvatar(
                fullName: name,
                avatarUrl: member.avatarUrl,
                resolvedImageUrl: member.avatarUrl,
                radius: 23,
                backgroundColor: AppTheme.avatarBg,
                foregroundColor: AppTheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      number,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (record == null)
                const Text(
                  'درخواستی نیست',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                )
              else
                _StatusLabel(status: record!.status),
            ],
          ),
          if (record?.status == 'pending') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: saving
                        ? null
                        : () => onReview(record!, 'approved'),
                    child: const Text('تأیید • ۱ امتیاز'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: saving
                        ? null
                        : () => onReview(record!, 'rejected'),
                    child: const Text('رد درخواست'),
                  ),
                ),
              ],
            ),
          ] else if (record == null ||
              record!.status == 'rejected' ||
              record!.status == 'absent' ||
              record!.status == 'approved') ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (record?.status != 'approved')
                  OutlinedButton.icon(
                    onPressed: saving
                        ? null
                        : record == null
                        ? () => onSetAttendance?.call(member, 'approved')
                        : () => onReview(record!, 'approved'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('ثبت حضور • ۱ امتیاز'),
                  ),
                if (session.isEnded && record?.status != 'absent')
                  TextButton.icon(
                    onPressed: saving
                        ? null
                        : record == null
                        ? () => onSetAttendance?.call(member, 'absent')
                        : () => onReview(record!, 'absent'),
                    icon: const Icon(Icons.person_off_outlined),
                    label: const Text('ثبت غیبت'),
                  ),
                if (!session.isEnded && record?.status == 'approved')
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => onReview(record!, 'rejected'),
                    child: const Text('برگرداندن تأیید'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _AttendanceCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Card(
    color: AppTheme.cardBg,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppTheme.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (trailing != null)
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  child: trailing!,
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final String value;
  final String detail;

  const _ScoreBox({
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.primaryLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _StatusLabel extends StatelessWidget {
  final String status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'approved' => ('تأیید شده', AppTheme.success),
      'absent' => ('غایب', AppTheme.error),
      'rejected' => ('رد شده', AppTheme.error),
      _ => ('در انتظار بررسی', AppTheme.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AttendanceLoadError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _AttendanceLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش دوباره'),
          ),
        ],
      ),
    ),
  );
}

class _ScheduleEditor extends StatefulWidget {
  final AttendanceSchedule? schedule;

  const _ScheduleEditor({this.schedule});

  @override
  State<_ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<_ScheduleEditor> {
  late int _weekday;
  late TimeOfDay _startsAt;
  late TimeOfDay _endsAt;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    _weekday = schedule?.weekday ?? DateTime.monday;
    _startsAt =
        _parseTime(schedule?.startsAt) ?? const TimeOfDay(hour: 8, minute: 0);
    _endsAt =
        _parseTime(schedule?.endsAt) ?? const TimeOfDay(hour: 9, minute: 0);
    _isActive = schedule?.isActive ?? true;
  }

  Future<void> _pickTime({required bool start}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: start ? _startsAt : _endsAt,
      helpText: start ? 'ساعت شروع کلاس' : 'ساعت پایان کلاس',
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (start) {
        _startsAt = selected;
      } else {
        _endsAt = selected;
      }
    });
  }

  void _save() {
    final startMinutes = _startsAt.hour * 60 + _startsAt.minute;
    final endMinutes = _endsAt.hour * 60 + _endsAt.minute;
    if (startMinutes >= endMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ساعت پایان باید بعد از شروع کلاس باشد.')),
      );
      return;
    }
    Navigator.of(context).pop(
      _ScheduleDraft(
        weekday: _weekday,
        startsAt: _formatTime(_startsAt),
        endsAt: _formatTime(_endsAt),
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.schedule == null ? 'برنامهٔ روز کلاس' : 'ویرایش برنامه',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _weekday,
            decoration: const InputDecoration(labelText: 'روز هفته'),
            items: [
              for (var day = 1; day <= 7; day++)
                DropdownMenuItem(value: day, child: Text(_weekdayName(day))),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _weekday = value);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(start: true),
                  icon: const Icon(Icons.schedule),
                  label: Text('شروع ${_startsAt.format(context)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(start: false),
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text('پایان ${_endsAt.format(context)}'),
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('برنامه فعال باشد'),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _save, child: const Text('ذخیره برنامه')),
        ],
      ),
    ),
  );
}

class _ScheduleDraft {
  final int weekday;
  final String startsAt;
  final String endsAt;
  final bool isActive;

  const _ScheduleDraft({
    required this.weekday,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
  });
}

String _weekdayName(int weekday) => switch (weekday) {
  DateTime.monday => 'دوشنبه',
  DateTime.tuesday => 'سه‌شنبه',
  DateTime.wednesday => 'چهارشنبه',
  DateTime.thursday => 'پنج‌شنبه',
  DateTime.friday => 'جمعه',
  DateTime.saturday => 'شنبه',
  DateTime.sunday => 'یکشنبه',
  _ => 'نامشخص',
};

TimeOfDay? _parseTime(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime(TimeOfDay value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}:00';

String _shortTime(String value) =>
    value.length >= 5 ? value.substring(0, 5) : value;

String _timeString(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}:00';

String _formatPoints(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';
