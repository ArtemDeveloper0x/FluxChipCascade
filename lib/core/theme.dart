import 'package:flutter/material.dart';

/// Neon futuristic palette shared across the whole app.
class AppColors {
  AppColors._();

  static const Color bgDeep = Color(0xFF05060F);
  static const Color bgPanel = Color(0xFF0C1024);
  static const Color panelBorder = Color(0xFF2C3B77);
  static const Color cyan = Color(0xFF3DE8FF);
  static const Color blue = Color(0xFF3D7CFF);
  static const Color magenta = Color(0xFFE93DFF);
  static const Color purple = Color(0xFF9B3DFF);
  static const Color green = Color(0xFF52FF7A);
  static const Color orange = Color(0xFFFF9A3D);
  static const Color gold = Color(0xFFFFD84D);
  static const Color red = Color(0xFFFF3D5A);
  static const Color textPrimary = Color(0xFFEAF3FF);
  static const Color textSecondary = Color(0xFF8FA3D1);
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgDeep,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.cyan,
        secondary: AppColors.magenta,
        surface: AppColors.bgPanel,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: 'Roboto',
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }

  static BoxDecoration panelDecoration({Color? glow}) {
    return BoxDecoration(
      color: AppColors.bgPanel.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: (glow ?? AppColors.panelBorder), width: 1.4),
      boxShadow: [
        BoxShadow(
          color: (glow ?? AppColors.cyan).withValues(alpha: 0.35),
          blurRadius: 18,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static TextStyle neonTitle({double size = 28, Color? color}) {
    final c = color ?? AppColors.cyan;
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: 1.2,
      shadows: [
        Shadow(color: c, blurRadius: 18),
        Shadow(color: c.withValues(alpha: 0.8), blurRadius: 36),
      ],
    );
  }
}
