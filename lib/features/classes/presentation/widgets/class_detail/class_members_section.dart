import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/profile/presentation/widgets/profile_avatar.dart';

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

class _StudentMemberCard extends StatelessWidget {
  final ClassMemberModel member;

  const _StudentMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final displayName = member.studentName ?? 'کاربر بدون نام';
    final displayNumber = member.studentNumber ?? 'بدون کد دانشجویی';

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
        leading: ProfileAvatar(
          fullName: displayName,
          avatarUrl: member.avatarUrl,
          radius: 24,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          foregroundColor: AppTheme.primary,
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
              tooltip: 'مشاهده پروفایل دانشجو',
              onPressed: () {
                context.pushNamed(
                  'student-profile',
                  queryParameters: {
                    'classId': member.classId,
                    'studentId': member.studentId,
                  },
                );
              },
              icon: const Icon(
                Icons.account_circle_outlined,
                color: AppTheme.primary,
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
