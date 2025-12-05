import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable button widgets

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final String size; // 'normal', 'small'

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = 'normal',
  });

  @override
  Widget build(BuildContext context) {
    final double verticalPadding = size == 'small' ? 12 : 16;
    final TextStyle textStyle = size == 'small'
        ? AppTextStyles.buttonSmall
        : AppTextStyles.button;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: verticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textOnPrimary,
                  ),
                ),
              )
            : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: size == 'small' ? 18 : 20),
                  const SizedBox(width: 8),
                  Text(text, style: textStyle),
                ],
              )
            : Text(text, style: textStyle),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final String size; // 'normal', 'small'

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = 'normal',
  });

  @override
  Widget build(BuildContext context) {
    final double verticalPadding = size == 'small' ? 12 : 16;
    final TextStyle textStyle = size == 'small'
        ? AppTextStyles.buttonSmall.copyWith(color: AppColors.primary)
        : AppTextStyles.button.copyWith(color: AppColors.primary);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight.withOpacity(0.1),
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: verticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: size == 'small' ? 18 : 20),
                  const SizedBox(width: 8),
                  Text(text, style: textStyle),
                ],
              )
            : Text(text, style: textStyle),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final String size; // 'normal', 'small'
  final Color? borderColor;
  final Color? textColor;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = 'normal',
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final double verticalPadding = size == 'small' ? 12 : 16;
    final Color finalBorderColor = borderColor ?? AppColors.primary;
    final Color finalTextColor = textColor ?? AppColors.primary;
    final TextStyle textStyle = size == 'small'
        ? AppTextStyles.buttonSmall.copyWith(color: finalTextColor)
        : AppTextStyles.button.copyWith(color: finalTextColor);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: finalTextColor,
          side: BorderSide(color: finalBorderColor, width: 2),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: verticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(finalTextColor),
                ),
              )
            : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: size == 'small' ? 18 : 20),
                  const SizedBox(width: 8),
                  Text(text, style: textStyle),
                ],
              )
            : Text(text, style: textStyle),
      ),
    );
  }
}

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  const IconTextButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = color ?? AppColors.primary;

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: buttonColor),
      label: Text(
        text,
        style: AppTextStyles.button.copyWith(color: buttonColor),
      ),
    );
  }
}
