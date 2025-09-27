import 'package:flutter/material.dart';

class AppConfig {
  // Colores principales
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color primaryLightColor = Color(0xFF42A5F5);
  static const Color primaryDarkColor = Color(0xFF1565C0);

  // Colores de gradiente claro
  static const Color lightGradientStart = Color(0xFFE3F2FD);
  static const Color lightGradientEnd = Color(0xFFFFFFFF);

  // Colores de gradiente oscuro
  static const Color darkGradientStart = Color(0xFF1A1A1A);
  static const Color darkGradientEnd = Color(0xFF121212);

  // Colores de tarjetas
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // Colores de texto
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF616161);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Colores de sombra
  static const Color lightShadowColor = Color(0xFF1E88E5);
  static const Color darkShadowColor = Color(0xFF000000);

  // Configuración de fuentes
  static const String fontFamily = 'SF Pro Display';

  // Configuración de animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
}
