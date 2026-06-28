import 'package:flutter/material.dart';
import 'package:karafarini/core/services/auth_services.dart';
import 'package:karafarini/core/theme/app_Theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final studentNumberController = TextEditingController();
  final teacherNumberController = TextEditingController();
  final phoneController = TextEditingController();
  final majorController = TextEditingController();
  final departmentController = TextEditingController();
  final bioController = TextEditingController();

  String role = 'student';
  bool loading = false;
  bool _obscurePassword = true;

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      await AuthService.instance.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fullName: fullNameController.text.trim(),
        role: role,
        studentNumber: role == 'student'
            ? studentNumberController.text.trim()
            : null,
        teacherNumber: role == 'professor'
            ? teacherNumberController.text.trim()
            : null,
        phone: phoneController.text.trim(),
        major: majorController.text.trim(),
        department: departmentController.text.trim(),
        bio: bioController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ثبت‌نام انجام شد. حالا وارد شو.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('ثبت‌نام'),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.primaryLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.border),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // ── بخش اطلاعات اصلی ──
            _SectionCard(
              icon: Icons.person_outline_rounded,
              title: 'اطلاعات اصلی',
              color: AppTheme.primary,
              children: [
                _field(
                  controller: fullNameController,
                  label: 'نام کامل',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: emailController,
                  label: 'ایمیل',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'example@email.com',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'رمز عبور',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── نقش ──
            _SectionCard(
              icon: Icons.school_outlined,
              title: 'نقش در سیستم',
              color: const Color(0xFF7C3AED),
              children: [
                // انتخاب نقش با تاگل
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _RoleTab(
                        label: 'دانشجو',
                        icon: Icons.person_outlined,
                        selected: role == 'student',
                        onTap: () => setState(() => role = 'student'),
                      ),
                      _RoleTab(
                        label: 'استاد',
                        icon: Icons.person_4_outlined,
                        selected: role == 'professor',
                        onTap: () => setState(() => role = 'professor'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (role == 'student')
                  _field(
                    controller: studentNumberController,
                    label: 'شماره دانشجویی',
                    icon: Icons.numbers_outlined,
                    keyboardType: TextInputType.number,
                  ),
                if (role == 'professor')
                  _field(
                    controller: teacherNumberController,
                    label: 'شماره پرسنلی',
                    icon: Icons.numbers_outlined,
                    keyboardType: TextInputType.number,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── اطلاعات تکمیلی ──
            _SectionCard(
              icon: Icons.info_outline_rounded,
              title: 'اطلاعات تکمیلی',
              color: const Color(0xFF0891B2),
              children: [
                _field(
                  controller: phoneController,
                  label: 'شماره تماس',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: majorController,
                  label: 'رشته تحصیلی',
                  icon: Icons.book_outlined,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: departmentController,
                  label: 'دانشکده / گروه',
                  icon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: bioController,
                  label: 'بیو (معرفی کوتاه)',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // دکمه ثبت‌نام
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('ثبت‌نام'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
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
}

// ─── Role Tab ─────────────────────────────────────────────────────────────────
class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:karafarini/core/services/auth_services.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final fullNameController = TextEditingController();
//   final studentNumberController = TextEditingController();
//   final teacherNumberController = TextEditingController();
//   final phoneController = TextEditingController();
//   final majorController = TextEditingController();
//   final departmentController = TextEditingController();
//   final bioController = TextEditingController();

//   String role = 'student';
//   bool loading = false;

//   Future<void> submit() async {
//     setState(() => loading = true);
//     try {
//       await AuthService.instance.signUp(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//         fullName: fullNameController.text.trim(),
//         role: role,
//         studentNumber: role == 'student'
//             ? studentNumberController.text.trim()
//             : null,
//         teacherNumber: role == 'professor'
//             ? teacherNumberController.text.trim()
//             : null,
//         phone: phoneController.text.trim(),
//         major: majorController.text.trim(),
//         department: departmentController.text.trim(),
//         bio: bioController.text.trim(),
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('ثبت‌نام انجام شد. حالا وارد شو.')),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('خطا: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('ثبت‌نام')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           TextField(
//             controller: fullNameController,
//             decoration: const InputDecoration(labelText: 'نام کامل'),
//           ),
//           TextField(
//             controller: emailController,
//             decoration: const InputDecoration(labelText: 'ایمیل'),
//           ),
//           TextField(
//             controller: passwordController,
//             decoration: const InputDecoration(labelText: 'رمز عبور'),
//             obscureText: true,
//           ),
//           DropdownButtonFormField(
//             value: role,
//             items: const [
//               DropdownMenuItem(value: 'student', child: Text('دانشجو')),
//               DropdownMenuItem(value: 'professor', child: Text('استاد')),
//             ],
//             onChanged: (value) => setState(() => role = value as String),
//             decoration: const InputDecoration(labelText: 'نقش'),
//           ),
//           if (role == 'student')
//             TextField(
//               controller: studentNumberController,
//               decoration: const InputDecoration(labelText: 'شماره دانشجویی'),
//             ),
//           if (role == 'professor')
//             TextField(
//               controller: teacherNumberController,
//               decoration: const InputDecoration(labelText: 'شماره پرسنلی'),
//             ),
//           TextField(
//             controller: phoneController,
//             decoration: const InputDecoration(labelText: 'شماره تماس'),
//           ),
//           TextField(
//             controller: majorController,
//             decoration: const InputDecoration(labelText: 'رشته'),
//           ),
//           TextField(
//             controller: departmentController,
//             decoration: const InputDecoration(labelText: 'دانشکده/گروه'),
//           ),
//           TextField(
//             controller: bioController,
//             decoration: const InputDecoration(labelText: 'بیو'),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: loading ? null : submit,
//             child: Text(loading ? 'در حال ثبت...' : 'ثبت‌نام'),
//           ),
//         ],
//       ),
//     );
//   }
// }
