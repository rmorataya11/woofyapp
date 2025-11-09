import '../models/appointment_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class AppointmentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Appointment>> getAppointments({
    String? status,
    String? petId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (petId != null) queryParams['pet_id'] = petId;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/appointments',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> appointmentsData;
      if (response.data is List) {
        appointmentsData = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final dataMap = response.data as Map<String, dynamic>;
        appointmentsData =
            (dataMap['appointments'] ?? dataMap['data'] ?? []) as List<dynamic>;
      } else {
        appointmentsData = [];
      }

      if (appointmentsData.isEmpty) return [];

      return appointmentsData
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Appointment> getAppointmentById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/appointments/$id',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Appointment.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Appointment> createAppointment({
    required String clinicId,
    required String petId,
    required String serviceId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? notes,
  }) async {
    try {
      final body = {
        'clinic_id': clinicId,
        'pet_id': petId,
        'service_id': serviceId,
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

      print('📅 Creando cita con datos: $body');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/appointments',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      print('📅 Respuesta del backend: ${response.data}');
      return Appointment.fromJson(response.data!);
    } catch (e) {
      print('📅 ❌ Error al crear cita: $e');
      rethrow;
    }
  }

  Future<Appointment> updateAppointment({
    required String id,
    DateTime? startsAt,
    DateTime? endsAt,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (startsAt != null) body['starts_at'] = startsAt.toIso8601String();
      if (endsAt != null) body['ends_at'] = endsAt.toIso8601String();
      if (notes != null) body['notes'] = notes;

      print('📅 Actualizando cita $id con datos: $body');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/appointments/$id',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      print('📅 Respuesta del backend: ${response.data}');
      return Appointment.fromJson(response.data!);
    } catch (e) {
      print('📅 ❌ Error al actualizar cita: $e');
      rethrow;
    }
  }

  Future<Appointment> updateAppointmentStatus({
    required String id,
    required String status,
  }) async {
    try {
      final body = {'status': status};

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/appointments/$id/status',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Appointment.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      final response = await _apiClient.delete(
        '/appointments/$id',
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

  Future<List<AppointmentRequest>> getAppointmentRequests({
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/appointment-requests',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> requestsData;
      if (response.data is List) {
        requestsData = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final dataMap = response.data as Map<String, dynamic>;
        requestsData =
            (dataMap['requests'] ?? dataMap['data'] ?? []) as List<dynamic>;
      } else {
        requestsData = [];
      }

      if (requestsData.isEmpty) return [];

      return requestsData
          .map(
            (json) => AppointmentRequest.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmAppointmentRequest({
    required String requestId,
    String? finalDate,
    String? finalTime,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (finalDate != null) body['final_date'] = finalDate;
      if (finalTime != null) body['final_time'] = finalTime;
      if (notes != null) body['notes'] = notes;

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/appointment-requests/$requestId/confirm',
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

  Future<void> cancelAppointmentRequest({
    required String requestId,
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (reason != null) body['reason'] = reason;

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/appointment-requests/$requestId/cancel',
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
}
