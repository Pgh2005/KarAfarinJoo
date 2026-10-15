import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/core/widgets/responsive_scaffold.dart';
import 'package:karafarini/features/profile/models/profile.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentSessionProfileProvider);

    return ResponsiveScaffold(
      backgroundColor: AppTheme.surface,
      appBar: const AppBarBuilder(
        title: 'پروفایل',
        automaticallyImplyLeading: false,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'خطا در دریافت اطلاعات پروفایل',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_off_outlined,
                      size: 48,
                      color: AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'اطلاعات کاربر پیدا نشد',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Header Section with Avatar ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        // Avatar with shadow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: Colors.white,
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? Text(
                                    _getInitials(profile.fullName),
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Name
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            profile.role == UserRole.student
                                ? 'دانشجو'
                                : 'استاد',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // ── Profile Information Cards ──
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Contact Information Card
                      _buildInfoCard(
                        title: 'اطلاعات تماس',
                        icon: Icons.contact_mail_outlined,
                        children: [
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            label: 'ایمیل',
                            value: profile.email,
                          ),
                          if (profile.phone != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.phone_outlined,
                              label: 'شماره تماس',
                              value: profile.phone!,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Academic Information Card
                      _buildInfoCard(
                        title: 'اطلاعات دانشگاهی',
                        icon: Icons.school_outlined,
                        children: [
                          if (profile.role == UserRole.student &&
                              profile.studentNumber != null)
                            _buildInfoRow(
                              icon: Icons.badge_outlined,
                              label: 'شماره دانشجویی',
                              value: profile.studentNumber!,
                            ),
                          if (profile.role == UserRole.professor &&
                              profile.teacherNumber != null)
                            _buildInfoRow(
                              icon: Icons.badge_outlined,
                              label: 'شماره استادی',
                              value: profile.teacherNumber!,
                            ),
                          if (profile.major != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.menu_book_outlined,
                              label: 'رشته تحصیلی',
                              value: profile.major!,
                            ),
                          ],
                          if (profile.department != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.business_outlined,
                              label: 'دانشکده',
                              value: profile.department!,
                            ),
                          ],
                        ],
                      ),

                      // Bio Card (if available)
                      if (profile.bio != null) ...[
                        const SizedBox(height: 14),
                        _buildInfoCard(
                          title: 'درباره من',
                          icon: Icons.info_outlined,
                          children: [
                            Text(
                              profile.bio!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final shouldLogout = await _showLogoutDialog(
                              context,
                            );
                            if (shouldLogout == true) {
                              await ref.read(supabaseProvider).auth.signOut();
                              ref.invalidate(currentSessionProfileProvider);

                              if (context.mounted) {
                                context.go('/login');
                              }
                            }
                          },
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text(
                            'خروج از حساب کاربری',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryLight, AppTheme.cardBg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[words.length - 1][0]).toUpperCase();
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'خروج از حساب',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید از حساب کاربری خود خارج شوید؟',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'انصراف',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
            child: const Text(
              'خروج',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
