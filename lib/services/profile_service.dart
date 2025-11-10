import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<Profile> getMyProfile() async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/profiles/me',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Profile.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Profile> updateMyProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? bio,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (location != null) body['location'] = location;
      if (bio != null) body['bio'] = bio;

      final response = await _apiClient.put<dynamic>(
        '/profiles/me',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Profile.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPreferences> getMyPreferences() async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/profiles/me/preferences',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        return UserPreferences.defaultPreferences();
      }

      return UserPreferences.fromJson(response.data!);
    } catch (e) {
      return UserPreferences.defaultPreferences();
    }
  }

  Future<UserPreferences> updateMyPreferences(
    UserPreferences preferences,
  ) async {
    try {
      final response = await _apiClient.put<dynamic>(
        '/profiles/me/preferences',
        body: preferences.toJson(),
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return UserPreferences.fromJson(
        response.data!['preferences'] as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final response = await _apiClient.postMultipart<Map<String, dynamic>>(
        '/upload/avatar',
        fields: {},
        fileField: 'avatar',
        filePath: filePath,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return response.data!['avatar_url'] as String;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAvatar() async {
    try {
      final response = await _apiClient.delete(
        '/upload/avatar',
        requiresAuth: true,
      );

      if (!response.success) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener la ubicación del usuario (coordenadas) desde el backend
  /// Si el endpoint falla, usa coordenadas por defecto (ESEN)
  Future<Map<String, double>> getUserLocation() async {
    try {
      // Intentar obtener desde endpoint específico de ubicación
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/user/location',
        requiresAuth: false, // Cambia a true si requiere autenticación
      );

      if (!response.success || response.data == null) {
        // Si falla, usar coordenadas por defecto (ESEN)
        debugPrint(
          '⚠️ No se pudo obtener ubicación del backend, usando coordenadas por defecto',
        );
        return {
          'latitude': 13.6553, // ESEN default
          'longitude': -89.2860, // ESEN default
        };
      }

      final data = response.data!;
      final latValue = data['latitude'] ?? data['lat'];
      final lngValue = data['longitude'] ?? data['lng'] ?? data['lon'];
      final lat = latValue?.toDouble();
      final lng = lngValue?.toDouble();

      if (lat == null || lng == null) {
        // Si las coordenadas son inválidas, usar por defecto
        debugPrint('⚠️ Coordenadas inválidas, usando coordenadas por defecto');
        return {
          'latitude': 13.6553, // ESEN default
          'longitude': -89.2860, // ESEN default
        };
      }

      return {'latitude': lat, 'longitude': lng};
    } catch (e) {
      // Si hay cualquier error, usar coordenadas por defecto
      debugPrint(
        '⚠️ Error obteniendo ubicación: $e, usando coordenadas por defecto',
      );
      return {
        'latitude': 13.6553, // ESEN default
        'longitude': -89.2860, // ESEN default
      };
    }
  }
}
