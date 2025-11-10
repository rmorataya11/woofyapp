import '../models/user_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<dynamic>(
        '/auth/login',
        body: {'email': email, 'password': password},
        requiresAuth: false,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final authResponse = AuthResponse.fromJson(response.data!);

      // Guardar tokens en el ApiClient
      await _apiClient.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Signup (registro) de nuevo usuario
  Future<AuthResponse> signup({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _apiClient.post<dynamic>(
        '/auth/signup',
        body: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
        requiresAuth: false,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final authResponse = AuthResponse.fromJson(response.data!);

      // Guardar tokens en el ApiClient
      await _apiClient.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener usuario actual
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/auth/me',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return User.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Refrescar access token usando refresh token
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();

      if (refreshToken == null) {
        throw UnauthorizedException(message: 'No hay refresh token disponible');
      }

      final response = await _apiClient.post<dynamic>(
        '/auth/refresh',
        body: {'refresh_token': refreshToken},
        requiresAuth: false,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final authResponse = AuthResponse.fromJson(response.data!);

      // Actualizar tokens
      await _apiClient.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } catch (e) {
      // Si falla el refresh, limpiar tokens
      await logout();
      rethrow;
    }
  }

  /// Logout (cerrar sesión)
  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  /// Verificar si hay una sesión activa
  Future<bool> hasActiveSession() async {
    return await _apiClient.hasValidToken();
  }

  /// Verificar y refrescar token si es necesario
  Future<bool> checkAndRefreshToken() async {
    try {
      final hasToken = await hasActiveSession();
      if (!hasToken) return false;

      // Intentar obtener el usuario actual para verificar que el token es válido
      await getCurrentUser();
      return true;
    } on UnauthorizedException {
      // Token inválido o expirado, intentar refrescar
      try {
        await refreshToken();
        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
