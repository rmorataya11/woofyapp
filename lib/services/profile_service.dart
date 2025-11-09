import '../models/profile_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<Profile> getMyProfile() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
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

      final response = await _apiClient.put<Map<String, dynamic>>(
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
      final response = await _apiClient.get<Map<String, dynamic>>(
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
      final response = await _apiClient.put<Map<String, dynamic>>(
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
}
