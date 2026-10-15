import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karafarini/features/auth/data/auth_services.dart';
import 'package:karafarini/core/theme/app_Theme.dart';
import 'package:karafarini/core/widgets/loading_indicator.dart';
import 'package:karafarini/core/widgets/responsive_scaffold.dart';
import 'package:karafarini/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:karafarini/features/auth/presentation/widgets/role_selector.dart';
import 'package:karafarini/features/forms/widgets/info_hint_box.dart';
import 'package:karafarini/features/forms/widgets/section_card.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
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

  late final AnimationController _headerCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  late final AnimationController _cardsCtrl;
  late final Animation<double> _cardsFade;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardsFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOut));

    _headerCtrl.forward().then((_) => _cardsCtrl.forward());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    studentNumberController.dispose();
    teacherNumberController.dispose();
    phoneController.dispose();
    majorController.dispose();
    departmentController.dispose();
    bioController.dispose();
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final studentNumber = studentNumberController.text.trim();
    final teacherNumber = teacherNumberController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('نام کامل، ایمیل و رمز عبور الزامی است.'),
              backgroundColor: Colors.red,
            ),
          );
      }
      return;
    }

    if (role == 'student' && studentNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('لطفاً شماره دانشجویی خود را وارد کنید.'),
              backgroundColor: Colors.red,
            ),
          );
      }
      return;
    }

    if (role == 'professor' && teacherNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('لطفاً شماره پرسنلی خود را وارد کنید.'),
              backgroundColor: Colors.red,
            ),
          );
      }
      return;
    }

    setState(() => loading = true);
    try {
      await AuthService.instance.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        studentNumber: role == 'student' ? studentNumber : null,
        teacherNumber: role == 'professor' ? teacherNumber : null,
        phone: phoneController.text.trim(),
        major: majorController.text.trim(),
        department: departmentController.text.trim(),
        bio: bioController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('ثبت‌نام انجام شد. حالا وارد شوید.')),
          );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(AuthService.formatAuthError(e)),
              backgroundColor: Colors.red,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppTheme.surface,
          body: ResponsiveContentWrapper(
            child: CustomScrollView(
            slivers: [
              // ── Hero Header ──
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _SignupHeader(screenHeight: size.height),
                  ),
                ),
              ),

              // ── Form body ──
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _cardsFade,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Step label
                        _StepHeader(
                          step: 1,
                          total: 3,
                          title: 'اطلاعات اصلی',
                          subtitle: 'نام، ایمیل و رمز عبور خود را وارد کنید',
                        ),
                        const SizedBox(height: 12),

                        SectionCard(
                          icon: Icons.person_outline_rounded,
                          title: 'اطلاعات شخصی',
                          children: [
                            AuthTextField(
                              controller: fullNameController,
                              label: 'نام کامل',
                              prefixIcon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: emailController,
                              label: 'ایمیل',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              hint: 'example@email.com',
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: passwordController,
                              label: 'رمز عبور',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: true,
                              showToggle: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _StepHeader(
                          step: 2,
                          total: 3,
                          title: 'نقش و شناسه',
                          subtitle: 'دانشجو یا استاد هستید؟',
                        ),
                        const SizedBox(height: 12),

                        SectionCard(
                          icon: Icons.school_rounded,
                          title: 'نقش دانشگاهی',
                          children: [
                            RoleSelector(
                              selectedRole: role,
                              onChanged: (v) => setState(() => role = v),
                            ),
                            const SizedBox(height: 14),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(
                                    opacity: anim,
                                    child: SizeTransition(
                                      sizeFactor: anim,
                                      axisAlignment: -1,
                                      child: child,
                                    ),
                                  ),
                              child: role == 'student'
                                  ? Column(
                                      key: const ValueKey('student'),
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        AuthTextField(
                                          controller: studentNumberController,
                                          label: 'شماره دانشجویی',
                                          prefixIcon: Icons.tag_rounded,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      key: const ValueKey('professor'),
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        AuthTextField(
                                          controller: teacherNumberController,
                                          label: 'شماره پرسنلی',
                                          prefixIcon: Icons.badge_rounded,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _StepHeader(
                          step: 3,
                          total: 3,
                          title: 'اطلاعات تکمیلی',
                          subtitle: 'این اطلاعات پروفایل شما را تکمیل می‌کند',
                        ),
                        const SizedBox(height: 12),

                        SectionCard(
                          icon: Icons.info_outline_rounded,
                          title: 'جزئیات بیشتر',
                          children: [
                            AuthTextField(
                              controller: phoneController,
                              label: 'شماره تماس',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: majorController,
                              label: 'رشته تحصیلی',
                              prefixIcon: Icons.auto_stories_outlined,
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: departmentController,
                              label: 'دانشکده / گروه',
                              prefixIcon: Icons.account_balance_outlined,
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: bioController,
                              label: 'بیوگرافی',
                              prefixIcon: Icons.edit_note_rounded,
                              maxLines: 3,
                              hint: 'کمی درباره خودت بنویس...',
                            ),
                            const SizedBox(height: 14),
                            InfoHintBox(
                              text:
                                  'این اطلاعات فقط برای تکمیل پروفایل است و هر زمان قابل ویرایش می‌باشد.',
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ── Submit Button ──
                        _SignupButton(loading: loading, onPressed: submit),

                        const SizedBox(height: 16),

                        // ── Login Link ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'قبلاً ثبت‌نام کرده‌اید؟',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                'وارد شوید',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Hero header — gradient with logo + tagline + wave clip
// ──────────────────────────────────────────────────────────────────────────────

class _SignupHeader extends StatelessWidget {
  final double screenHeight;
  const _SignupHeader({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        height: screenHeight * 0.30,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppTheme.primaryDark, AppTheme.primary, Color(0xFF2196F3)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -18,
                left: -18,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon badge
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ایجاد حساب کاربری',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'به جامعه کارآفرین‌جو بپیوندید',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 16,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 32,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}

// ──────────────────────────────────────────────────────────────────────────────
// Step header — numbered step indicator
// ──────────────────────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final String subtitle;

  const _StepHeader({
    required this.step,
    required this.total,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Step badge
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Step dots
        Row(
          children: List.generate(total, (i) {
            final active = i == step - 1;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 4),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : AppTheme.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Signup submit button with shimmer-like pulse on loading
// ──────────────────────────────────────────────────────────────────────────────

class _SignupButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _SignupButton({required this.loading, required this.onPressed});

  @override
  State<_SignupButton> createState() => _SignupButtonState();
}

class _SignupButtonState extends State<_SignupButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.loading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withValues(alpha: 0.15),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: widget.loading
                    ? const AppLoadingIndicator(
                        key: ValueKey('loading'),
                        size: 24,
                        strokeWidth: 2.5,
                        color: Colors.white,
                      )
                    : const Row(
                        key: ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.how_to_reg_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'ثبت‌نام',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
