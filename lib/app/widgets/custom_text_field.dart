import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;
  final double borderWidth;
  final double borderRadius;
  final bool enabled;
  final int? maxLines;

  const CustomTextField({
    Key? key,
    this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.backgroundColor = AppColors.fieldBackground,
    this.borderColor = AppColors.fieldBorder,
    this.textColor = AppColors.white,
    this.hintColor,
    this.borderWidth = 2.0,
    this.borderRadius = 12.0,
    this.enabled = true,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      focusNode: _focusNode,
      style: AppTextStyles.bodyMedium.copyWith(
        color: widget.textColor,
      ),
      decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: widget.backgroundColor,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: widget.hintColor ?? widget.textColor?.withValues(alpha: 0.6),
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: widget.textColor,
          ),
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          errorMaxLines: 2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor!,
              width: widget.borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor!,
              width: widget.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: _isFocused 
                  ? (widget.borderColor == AppColors.white || widget.borderWidth == 0 
                      ? AppColors.primary 
                      : widget.borderColor!)
                  : widget.borderColor!,
              width: _isFocused ? 2.5 : widget.borderWidth,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: AppColors.error,
              width: widget.borderWidth,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: AppColors.error,
              width: widget.borderWidth,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor!.withValues(alpha: 0.5),
              width: widget.borderWidth,
            ),
          ),
        ),
      );
  }
}