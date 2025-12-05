import 'package:flutter/material.dart';

/// App color palette - Bank Sampah Alma Magelang
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2E7D32); // Green - representing sustainability
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  
  // Secondary colors
  static const Color secondary = Color(0xFF1976D2); // Blue
  static const Color secondaryLight = Color(0xFF63A4FF);
  static const Color secondaryDark = Color(0xFF004BA0);
  
  // Accent colors
  static const Color accent = Color(0xFFFF6F00); // Orange
  static const Color accentLight = Color(0xFFFFA040);
  static const Color accentDark = Color(0xFFC43E00);
  
  // Neutral colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE0E0E0);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Transaction status colors
  static const Color statusProses = Color(0xFFFF9800); // Orange
  static const Color statusDijemput = Color(0xFF2196F3); // Blue
  static const Color statusSelesai = Color(0xFF4CAF50); // Green
  static const Color statusDibatalkan = Color(0xFFF44336); // Red
  
  // Withdrawal status colors
  static const Color statusPending = Color(0xFFFF9800); // Orange
  static const Color statusTerverifikasi = Color(0xFF4CAF50); // Green
  static const Color statusRejected = Color(0xFFF44336); // Red
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
