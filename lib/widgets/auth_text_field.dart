import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karafarini/core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final bool showToggle;
  final TextInputType keyboardType;
  final String? hint;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.showToggle = false,
    this.keyboardType = TextInputType.text,
    this.hint,
    this.maxLines = 1,
    this.inputFormatters,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField>
    with SingleTickerProviderStateMixin {
  late bool _obscure;
  late final FocusNode _focus;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focus = FocusNode();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _glowAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut),
    );
    _focus.addListener(() {
      if (_focus.hasFocus) {
        _glowCtrl.forward();
      } else {
        _glowCtrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: _glowAnim.value * 0.18),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        inputFormatters: widget.inputFormatters,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: AppTheme.textHint,
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 4, left: 2),
            child: Icon(
              widget.prefixIcon,
              color: _focus.hasFocus ? AppTheme.primary : AppTheme.textHint,
              size: 20,
            ),
          ),
          suffixIcon: widget.showToggle
              ? IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ),
      ),
    );
  }
}
