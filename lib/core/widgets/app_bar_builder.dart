import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';

class AppBarBuilder extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const AppBarBuilder({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primary,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: leading,
      leadingWidth: 64,
      actions: actions,
      actionsPadding: const EdgeInsetsDirectional.only(end: 8),
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ), // برای دکمه بک پیش‌فرض
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.border),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
