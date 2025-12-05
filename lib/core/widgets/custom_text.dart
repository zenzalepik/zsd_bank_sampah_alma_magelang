import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

/// Reusable text widgets with predefined styles

class HeadingText extends StatelessWidget {
  final String text;
  final int level; // 1-5
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const HeadingText(
    this.text, {
    super.key,
    this.level = 1,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : assert(level >= 1 && level <= 5, 'Level must be between 1 and 5');

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    switch (level) {
      case 1:
        style = AppTextStyles.h1;
        break;
      case 2:
        style = AppTextStyles.h2;
        break;
      case 3:
        style = AppTextStyles.h3;
        break;
      case 4:
        style = AppTextStyles.h4;
        break;
      case 5:
        style = AppTextStyles.h5;
        break;
      default:
        style = AppTextStyles.h1;
    }

    if (color != null) {
      style = style.copyWith(color: color);
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class BodyText extends StatelessWidget {
  final String text;
  final String size; // 'large', 'medium', 'small'
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const BodyText(
    this.text, {
    super.key,
    this.size = 'medium',
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    switch (size) {
      case 'large':
        style = AppTextStyles.bodyLarge;
        break;
      case 'small':
        style = AppTextStyles.bodySmall;
        break;
      default:
        style = AppTextStyles.bodyMedium;
    }

    if (color != null) {
      style = style.copyWith(color: color);
    }

    if (fontWeight != null) {
      style = style.copyWith(fontWeight: fontWeight);
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class CaptionText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CaptionText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style = AppTextStyles.caption;

    if (color != null) {
      style = style.copyWith(color: color);
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class PriceText extends StatelessWidget {
  final double amount;
  final String size; // 'normal', 'small'
  final Color? color;
  final String prefix;

  const PriceText(
    this.amount, {
    super.key,
    this.size = 'normal',
    this.color,
    this.prefix = 'Rp ',
  });

  String _formatCurrency(double amount) {
    final String amountStr = amount.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amountStr.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = size == 'small'
        ? AppTextStyles.priceSmall
        : AppTextStyles.price;

    if (color != null) {
      style = style.copyWith(color: color);
    }

    return Text('$prefix${_formatCurrency(amount)}', style: style);
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final String type; // 'transaction' or 'withdrawal'

  const StatusBadge({
    super.key,
    required this.status,
    this.type = 'transaction',
  });

  Color _getStatusColor() {
    if (type == 'transaction') {
      switch (status.toLowerCase()) {
        case 'proses':
          return AppColors.statusProses;
        case 'dijemput':
          return AppColors.statusDijemput;
        case 'selesai':
          return AppColors.statusSelesai;
        case 'dibatalkan':
          return AppColors.statusDibatalkan;
        default:
          return AppColors.textSecondary;
      }
    } else {
      switch (status.toLowerCase()) {
        case 'pending':
          return AppColors.statusPending;
        case 'terverifikasi':
          return AppColors.statusTerverifikasi;
        case 'dibatalkan':
          return AppColors.statusRejected;
        default:
          return AppColors.textSecondary;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
