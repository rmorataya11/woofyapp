import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isDevelopment => dotenv.env['ENVIRONMENT'] == 'development';
  static bool get isProduction => dotenv.env['ENVIRONMENT'] == 'production';

  static int get requestTimeout =>
      int.tryParse(dotenv.env['REQUEST_TIMEOUT'] ?? '30') ?? 30;

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      log('⚠️ Error loading .env file: $e', name: 'Environment');
      log('Using default values', name: 'Environment');
    }
  }

  /// Imprimir configuración (solo para debug)
  static void printConfig() {
    log('🔧 Environment Configuration:', name: 'Environment');
    log('   BASE_URL: $baseUrl', name: 'Environment');
    log(
      '   ENVIRONMENT: ${isDevelopment ? "development" : "production"}',
      name: 'Environment',
    );
    log('   REQUEST_TIMEOUT: ${requestTimeout}s', name: 'Environment');
  }
}
