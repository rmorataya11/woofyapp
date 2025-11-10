import '../models/clinic_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class ClinicService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Clinic>> getClinics() async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/clinics',
        requiresAuth: false,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final clinicsData = response.data as List<dynamic>? ?? [];

      return clinicsData
          .map((json) => Clinic.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Clinic>> getNearbyClinics({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final response = await _apiClient.get<dynamic>(
        '/clinics/nearby',
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final clinicsData = response.data!['clinics'] as List<dynamic>?;
      if (clinicsData == null) return [];

      return clinicsData
          .map((json) => Clinic.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Clinic> getClinicById(String id) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/clinics/$id',
        requiresAuth: false,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Clinic.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ClinicServiceModel>> getClinicServices(String clinicId) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/clinics/$clinicId/services',
        requiresAuth: false,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final servicesData = response.data as List<dynamic>? ?? [];

      return servicesData
          .map(
            (json) => ClinicServiceModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ClinicHours> getClinicHours(String clinicId) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/clinics/$clinicId/hours',
        requiresAuth: false,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return ClinicHours.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> contactClinic({
    required String clinicId,
    required String name,
    required String email,
    String? phone,
    required String message,
    String? subject,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'message': message,
        if (phone != null) 'phone': phone,
        if (subject != null) 'subject': subject,
      };

      final response = await _apiClient.post<dynamic>(
        '/clinics/$clinicId/contact',
        body: body,
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

  Future<Map<String, dynamic>> requestAppointment({
    required String clinicId,
    required String petId,
    required String preferredDate,
    required String preferredTime,
    required String serviceType,
    required String reason,
    String? notes,
  }) async {
    try {
      final body = {
        'pet_id': petId,
        'preferred_date': preferredDate,
        'preferred_time': preferredTime,
        'service_type': serviceType,
        'reason': reason,
        if (notes != null) 'notes': notes,
      };

      final response = await _apiClient.post<dynamic>(
        '/clinics/$clinicId/request-appointment',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return response.data!;
    } catch (e) {
      rethrow;
    }
  }
}
