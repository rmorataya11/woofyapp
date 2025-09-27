import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_config.dart';
import '../providers/theme_provider.dart';

// Utilidades para gradientes y colores basados en el tema
class ThemeUtils {
  static BoxDecoration getBackgroundDecoration(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isDark = ref.watch(isDarkModeProvider);

    return BoxDecoration(
      gradient: isDark
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppConfig.darkGradientStart, AppConfig.darkGradientEnd],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConfig.lightGradientStart,
                AppConfig.lightGradientEnd,
              ],
            ),
    );
  }

  static Color getCardColor(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? AppConfig.darkCardColor : AppConfig.lightCardColor;
  }

  static Color getTextPrimaryColor(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? AppConfig.darkTextPrimary : AppConfig.lightTextPrimary;
  }

  static Color getTextSecondaryColor(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary;
  }

  static Color getShadowColor(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark
        ? AppConfig.darkShadowColor.withOpacity(0.3)
        : AppConfig.lightShadowColor.withOpacity(0.1);
  }
}
