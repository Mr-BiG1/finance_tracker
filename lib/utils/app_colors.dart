import 'package:flutter/material.dart';

class AppColors {
  // Primary Color Palette
  static const Color primary = Color(0xFF9C27B0); // Purple accent
  static const Color primaryDark = Color(0xFF7B1FA2);
  static const Color primaryLight = Color(0xFFE1BEE7);
  static const Color primaryVariant = Color(0xFFBA68C8);

  // Secondary Color Palette
  static const Color secondary = Color(0xFF00C9FF);
  static const Color secondaryDark = Color(0xFF0097A7);
  static const Color secondaryLight = Color(0xFF80D8FF);

  // Background/Surface Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color card = Color(0xFF292929);
  static const Color dialogBackground = Color(0xFF373737);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textDisabled = Color(0xFF616161);
  static const Color textHint = Color(0xFF757575);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFB0BEC5);
  static const Color darkGrey = Color(0xFF424242);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Opacity Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color primaryWithOpacity(double opacity) =>
      withOpacity(primary, opacity);
  static Color whiteWithOpacity(double opacity) => withOpacity(white, opacity);
  static Color blackWithOpacity(double opacity) => withOpacity(black, opacity);
}

class AppDimens {
  // Border Radius
  static const double cardRadius = 12;
  static const double buttonRadius = 8;
  static const double dialogRadius = 16;

  // Padding
  static const double smallPadding = 8;
  static const double mediumPadding = 16;
  static const double largePadding = 24;

  // Other Dimensions
  static const double appBarHeight = 56;
  static const double iconSize = 24;
}
