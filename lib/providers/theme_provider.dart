import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  return ThemeNotifier();
});

final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
});

final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', newMode == ThemeMode.dark);
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (state != mode) {
      state = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', mode == ThemeMode.dark);
    }
  }
}

// Extension para los temas
extension AppTheme on AppConfig {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: AppConfig.fontFamily,
      scaffoldBackgroundColor: AppConfig.lightGradientEnd,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppConfig.lightCardColor,
        elevation: 2,
        shadowColor: AppConfig.lightShadowColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConfig.lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConfig.lightTextPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppConfig.lightTextPrimary),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppConfig.lightTextSecondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: AppConfig.fontFamily,
      scaffoldBackgroundColor: AppConfig.darkGradientEnd,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppConfig.darkCardColor,
        elevation: 4,
        shadowColor: AppConfig.darkShadowColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConfig.darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConfig.darkTextPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppConfig.darkTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: AppConfig.darkTextSecondary),
      ),
    );
  }
}
