import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassMembersSection extends ConsumerStatefulWidget {
  final String classId;

  const ClassMembersSection({super.key, required this.classId});

  @override
  ConsumerState<ClassMembersSection> createState() =>
      _TeacherClassMembersSectionState();
}

class _TeacherClassMembersSectionState
    extends ConsumerState<ClassMembersSection> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(classMembersProvider(widget.classId));

    return membersAsync.when(
      data: (members) => _MembersContent(
        members: members,
        searchController: _searchController,
        searchQuery: _searchQuery,
        onSearchChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(child: Text('خطا در دریافت لیست اعضا: $err')),
    );
  }
}

class _MembersContent extends StatelessWidget {
  final List<ClassMemberModel> members;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _MembersContent({
    required this.members,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.toLowerCase().trim();

    final filtered = members.where((member) {
      final name = member.studentName?.toLowerCase() ?? '';
      final number = member.studentNumber?.toLowerCase() ?? '';
      return name.contains(query) || number.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_alt_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              'لیست دانشجویان (${members.length})',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'جستجوی نام یا شماره دانشجویی...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('دانشجویی یافت نشد'),
            ),
          )
        else
          ListView.builder(
            itemCount: filtered.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final member = filtered[index];
              return _StudentMemberCard(member: member);
            },
          ),
      ],
    );
  }
}

class _StudentMemberCard extends ConsumerStatefulWidget {
  final ClassMemberModel member;

  const _StudentMemberCard({required this.member});

  @override
  ConsumerState<_StudentMemberCard> createState() => _StudentMemberCardState();
}

class _StudentMemberCardState extends ConsumerState<_StudentMemberCard> {
  bool _isRemoving = false;

  Future<void> _removeStudent() async {
    final member = widget.member;
    final studentName = member.studentName ?? 'این دانشجو';
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف دانشجو از کلاس'),
        content: Text(
          '$studentName از این کلاس حذف می‌شود. پاسخ‌های فرم‌ها و حساب '
          'دانشجو حذف نخواهند شد.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف از کلاس'),
          ),
        ],
      ),
    );

    if (shouldRemove != true || !mounted) return;

    setState(() => _isRemoving = true);
    try {
      await ref
          .read(classActionsProvider)
          .removeStudentFromClass(
            classId: member.classId,
            studentId: member.studentId,
          );
      ref.invalidate(classMembersProvider(member.classId));
      ref.invalidate(studentClassesProvider);
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حذف دانشجو ناموفق بود: ${error.message}')),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حذف دانشجو ناموفق بود: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRemoving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final displayName = member.studentName ?? 'کاربر بدون نام';
    final displayNumber = member.studentNumber ?? 'بدون کد دانشجویی';
    final avatarText = displayName.isNotEmpty ? displayName[0] : 'U';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: AppTheme.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () {
          context.pushNamed(
            'form-list',
            queryParameters: {
              'classId': member.classId,
              'studentId': member.studentId,
              'studentName': member.studentName,
            },
          );
        },
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Text(
            avatarText,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('$displayNumber '),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'حذف دانشجو از کلاس',
              onPressed: _isRemoving ? null : _removeStudent,
              icon: _isRemoving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.person_remove_alt_1_outlined,
                      color: AppTheme.error,
                    ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
