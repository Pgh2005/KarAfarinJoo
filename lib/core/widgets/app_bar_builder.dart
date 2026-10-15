import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/utils/platform_utils.dart';

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

  bool _canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  Widget? _buildLeading(BuildContext context) {
    // Custom leading takes priority
    if (leading != null) return leading;

    // On web, show a back button if there's a route to go back to
    if (isWeb && _canPop(context)) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'بازگشت',
      );
    }

    // On mobile, Flutter handles the back button via automaticallyImplyLeading
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final webLeading = _buildLeading(context);

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
      leading: webLeading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.border),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
