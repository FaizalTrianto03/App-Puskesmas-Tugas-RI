import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 50,
    this.borderRadius = 12.0,
    this.borderWidth = 2.0,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isOutlined 
        ? Colors.transparent 
        : (backgroundColor ?? AppColors.buttonPrimary);
    
    final txtColor = textColor ?? 
        (isOutlined ? AppColors.white : AppColors.primary);
    
    final brdColor = borderColor ?? 
        (isOutlined ? AppColors.white : AppColors.primary);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: brdColor,
              width: borderWidth,
            ),
          ),
          elevation: isOutlined ? 0 : 2,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: txtColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
