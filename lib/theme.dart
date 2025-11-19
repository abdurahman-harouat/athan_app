/// OneUI Design System Library
/// A comprehensive design system mixing Samsung OneUI and Cupertino styles
///
/// Usage:
/// ```dart
/// import 'package:your_app/theme.dart';
///
/// // Use predefined colors (context-aware)
/// Container(color: AppColors.of(context).primary)
///
/// // Use typography
/// Text('Hello', style: AppTextStyles.titleLarge(context))
///
/// // Use spacing
/// SizedBox(height: AppSpacing.medium)
/// ```
library;

import 'package:flutter/cupertino.dart';

/// Design System Constants
class AppConstants {
  static const String fontFamily = 'ElMessiri';
  static const String monoFontFamily = 'SF Mono';

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}

/// Context-aware Color Palette
class AppColors {
  final Brightness brightness;

  AppColors._(this.brightness);

  /// Get colors based on current brightness
  static AppColors of(BuildContext context) {
    final brightness =
        CupertinoTheme.of(context).brightness ?? Brightness.light;
    return AppColors._(brightness);
  }

  bool get isDark => brightness == Brightness.dark;

  // Primary Colors
  Color get primary => CupertinoColors.systemBlue;
  Color get primaryLight => const Color(0xFF64B5F6);
  Color get primaryDark => const Color(0xFF1976D2);

  // Secondary Colors
  Color get secondary => CupertinoColors.systemGreen;
  Color get accent => CupertinoColors.systemOrange;

  // Neutral Colors
  Color get background => isDark
      ? CupertinoColors.systemGroupedBackground.darkColor
      : CupertinoColors.systemGroupedBackground;

  Color get surface => isDark
      ? CupertinoColors.systemBackground.darkColor
      : CupertinoColors.systemBackground;

  Color get cardBackground => isDark
      ? CupertinoColors.systemGrey6.darkColor
      : CupertinoColors.systemGrey6;

  // Liquid Glass Colors
  Color get glassBackground => surface.withValues(alpha: 0.7);

  Color get glassBorder => isDark
      ? CupertinoColors.systemGrey4.darkColor.withValues(alpha: 0.3)
      : CupertinoColors.systemGrey6.withValues(alpha: 0.3);

  Color get glassHighlight => isDark
      ? CupertinoColors.white.withValues(alpha: 0.05)
      : CupertinoColors.white.withValues(alpha: 0.1);

  // Text Colors - Context aware
  Color get textPrimary =>
      isDark ? CupertinoColors.label.darkColor : CupertinoColors.label;

  Color get textSecondary => isDark
      ? CupertinoColors.secondaryLabel.darkColor
      : CupertinoColors.secondaryLabel;

  Color get textTertiary => isDark
      ? CupertinoColors.tertiaryLabel.darkColor
      : CupertinoColors.tertiaryLabel;

  Color get textDisabled => CupertinoColors.systemGrey;

  // Status Colors
  Color get success => CupertinoColors.systemGreen;
  Color get warning => CupertinoColors.systemYellow;
  Color get error => CupertinoColors.destructiveRed;
  Color get info => CupertinoColors.systemBlue;

  // Interactive Colors
  Color get divider =>
      isDark ? CupertinoColors.separator.darkColor : CupertinoColors.separator;

  Color get border => isDark
      ? CupertinoColors.systemGrey4.darkColor
      : CupertinoColors.systemGrey4;

  // Utility Colors
  Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  Color blackWithOpacity(double opacity) =>
      CupertinoColors.black.withValues(alpha: opacity);
  Color whiteWithOpacity(double opacity) =>
      CupertinoColors.white.withValues(alpha: opacity);
}

/// Typography System with context-aware colors
class AppTextStyles {
  /// Get text color based on context
  static Color _getTextColor(BuildContext context) {
    return AppColors.of(context).textPrimary;
  }

  // Display Styles
  static TextStyle displayLarge(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w300,
        fontSize: 44.0,
        height: 1.2,
        letterSpacing: -0.5,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle displayMedium(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w300,
        fontSize: 36.0,
        height: 1.25,
        letterSpacing: -0.25,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  // Headline Styles
  static TextStyle headlineLarge(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 28.0,
        height: 1.3,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 24.0,
        height: 1.3,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle headlineSmall(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 22.0,
        height: 1.35,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  // Title Styles
  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 21.0,
        height: 1.4,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 20.0,
        height: 1.4,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle titleSmall(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 19.0,
        height: 1.4,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 19.0,
        height: 1.5,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
        height: 1.5,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 17.0,
        height: 1.5,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  // Label Styles
  static TextStyle labelLarge(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 17.0,
        height: 1.4,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle labelMedium(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        height: 1.4,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle labelSmall(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 15.0,
        height: 1.4,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  // Special Styles
  static TextStyle code(BuildContext context) => TextStyle(
        fontFamily: AppConstants.monoFontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
        letterSpacing: 4.0,
        height: 1.2,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 19.0,
        height: 1.2,
        color: _getTextColor(context),
        decoration: TextDecoration.none,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 15.0,
        height: 1.3,
        color: AppColors.of(context).textSecondary,
        decoration: TextDecoration.none,
      );
}

/// Spacing System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Semantic spacing
  static const double tiny = xs;
  static const double small = sm;
  static const double medium = md;
  static const double large = lg;
  static const double extraLarge = xl;
  static const double huge = xxl;
}

/// Border Radius System
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;

  // Semantic radius
  static const double small = xs;
  static const double medium = md;
  static const double large = lg;
  static const double card = md;
  static const double button = md;
  static const double input = sm;
}

/// Icon Sizes
class AppIconSizes {
  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Semantic sizes
  static const double small = sm;
  static const double medium = md;
  static const double large = lg;
}

/// Context-aware Liquid Glass Decorations
class AppDecorations {
  /// Creates a liquid glass effect decoration
  static BoxDecoration liquidGlass(
    BuildContext context, {
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Border? border,
  }) {
    final colors = AppColors.of(context);
    return BoxDecoration(
      color: backgroundColor ?? colors.glassBackground,
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
      border: border ?? Border.all(color: colors.glassBorder, width: 0.5),
    );
  }

  /// Creates a clean card decoration with soft borders (no shadows)
  static BoxDecoration cleanCard(
    BuildContext context, {
    BorderRadius? borderRadius,
  }) {
    final colors = AppColors.of(context);
    return BoxDecoration(
      color: colors.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
      border: Border.all(
        color: colors.glassBorder.withValues(alpha: 0.6),
        width: 1.0,
      ),
    );
  }

  /// Creates a soft expanded section decoration
  static BoxDecoration expandedSection(
    BuildContext context, {
    BorderRadius? borderRadius,
  }) {
    final colors = AppColors.of(context);
    return BoxDecoration(
      color: colors.background.withValues(alpha: 0.3),
      border: Border(
        top: BorderSide(
          color: colors.glassBorder.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
    );
  }
}

/// Complete Theme Data
class AppTheme {
  static final CupertinoThemeData lightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: CupertinoColors.systemBlue,
    barBackgroundColor: CupertinoColors.systemBackground,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
        height: 1.5,
        color: CupertinoColors.label,
        decoration: TextDecoration.none,
      ),
      actionTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 20.0,
        height: 1.4,
        color: CupertinoColors.systemBlue,
        decoration: TextDecoration.none,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        height: 1.4,
        color: CupertinoColors.secondaryLabel,
        decoration: TextDecoration.none,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 22.0,
        height: 1.35,
        color: CupertinoColors.label,
        decoration: TextDecoration.none,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w300,
        fontSize: 36.0,
        height: 1.25,
        letterSpacing: -0.25,
        color: CupertinoColors.label,
        decoration: TextDecoration.none,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
        height: 1.5,
        color: CupertinoColors.label,
        decoration: TextDecoration.none,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
        height: 1.5,
        color: CupertinoColors.label,
        decoration: TextDecoration.none,
      ),
    ),
  );

  static final CupertinoThemeData darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: CupertinoColors.systemBlue,
    barBackgroundColor: CupertinoColors.systemBackground.darkColor,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground.darkColor,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
        height: 1.5,
        color: CupertinoColors.label.darkColor,
        decoration: TextDecoration.none,
      ),
      actionTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 20.0,
        height: 1.4,
        color: CupertinoColors.systemBlue,
        decoration: TextDecoration.none,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        height: 1.4,
        color: CupertinoColors.secondaryLabel.darkColor,
        decoration: TextDecoration.none,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 22.0,
        height: 1.35,
        color: CupertinoColors.label.darkColor,
        decoration: TextDecoration.none,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w300,
        fontSize: 36.0,
        height: 1.25,
        letterSpacing: -0.25,
        color: CupertinoColors.label.darkColor,
        decoration: TextDecoration.none,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
        height: 1.5,
        color: CupertinoColors.label.darkColor,
        decoration: TextDecoration.none,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
        height: 1.5,
        color: CupertinoColors.label.darkColor,
        decoration: TextDecoration.none,
      ),
    ),
  );
}
