import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/utils/platform_utils.dart';

/// A responsive scaffold wrapper.
///
/// On mobile, behaves like a normal [Scaffold].
/// On web, constrains content to [Breakpoints.maxContentWidth] and centers it
/// with a subtle background, giving a desktop-friendly layout.
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > Breakpoints.maxContentWidth;

    if (!isWeb || !isWide) {
      // Mobile / narrow web: normal scaffold
      return Scaffold(
        backgroundColor: backgroundColor ?? AppTheme.surface,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      );
    }

    // Wide web: centered constrained layout
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: appBar,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
          child: Container(
            color: backgroundColor ?? AppTheme.surface,
            child: body,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }
}

/// A responsive wrapper for form content (like login, signup, etc.)
/// that centers and constrains width on wide screens.
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (!isWeb || width <= maxWidth) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
