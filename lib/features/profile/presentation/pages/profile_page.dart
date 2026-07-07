import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentSessionProfileProvider);

    return Scaffold(
      appBar: const AppBarBuilder(
        title: 'پروفایل',
        automaticallyImplyLeading: true,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'خطا در دریافت اطلاعات پروفایل:\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('اطلاعات کاربر پیدا نشد'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نام: ${profile.fullName}'),
                const SizedBox(height: 8),
                Text('ایمیل: ${profile.email}'),
                const SizedBox(height: 8),
                Text('نقش: ${profile.role.name}'),
                const SizedBox(height: 8),
                if (profile.studentNumber != null)
                  Text('شماره دانشجویی: ${profile.studentNumber}'),
                if (profile.teacherNumber != null)
                  Text('شماره استادی: ${profile.teacherNumber}'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(supabaseProvider).auth.signOut();
                      ref.invalidate(currentSessionProfileProvider);

                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    child: const Text('خروج از حساب'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
