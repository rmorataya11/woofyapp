import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Obtener el usuario actual
  static User? get currentUser => _client.auth.currentUser;

  // Verificar si el usuario está autenticado
  static bool get isAuthenticated => currentUser != null;

  // Stream de cambios de autenticación
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // Iniciar sesión con email y contraseña
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Registrarse con email y contraseña
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión con Google
  static Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.woofyapp://login-callback/',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Iniciar sesión con Apple
  static Future<bool> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.woofyapp://login-callback/',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Enviar email de recuperación de contraseña
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar perfil del usuario
  static Future<UserResponse> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          data: {
            if (name != null) 'name': name,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener datos del usuario
  static Map<String, dynamic>? getUserData() {
    final user = currentUser;
    if (user == null) return null;

    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['name'] ?? '',
      'avatar_url': user.userMetadata?['avatar_url'] ?? '',
      'created_at': user.createdAt,
    };
  }
}
