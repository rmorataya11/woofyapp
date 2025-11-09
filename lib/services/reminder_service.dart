import '../models/reminder_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class ReminderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Reminder>> getReminders({String? type, bool? upcoming}) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (upcoming != null) queryParams['upcoming'] = upcoming.toString();

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/reminders',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> remindersData;
      if (response.data is List) {
        remindersData = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final dataMap = response.data as Map<String, dynamic>;
        remindersData =
            (dataMap['reminders'] ?? dataMap['data'] ?? []) as List<dynamic>;
      } else {
        remindersData = [];
      }

      if (remindersData.isEmpty) return [];

      print('🔔 Recordatorios obtenidos: ${remindersData.length}');
      return remindersData
          .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('🔔 ❌ Error al obtener recordatorios: $e');
      rethrow;
    }
  }

  Future<Reminder> getReminderById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/reminders/$id',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Reminder.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Reminder> createReminder({
    required String petId,
    required String title,
    String? description,
    required DateTime dueAt,
    required String type,
  }) async {
    try {
      final body = {
        'title': title,
        'description': description,
        'due_at': dueAt.toIso8601String(),
        'type': type,
      };

      print('🔔 Creando recordatorio para pet $petId con datos: $body');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/reminders/pet/$petId',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      print('🔔 Respuesta del backend: ${response.data}');
      return Reminder.fromJson(response.data!);
    } catch (e) {
      print('🔔 ❌ Error al crear recordatorio: $e');
      rethrow;
    }
  }

  Future<Reminder> updateReminder({
    required String id,
    String? title,
    String? description,
    DateTime? dueAt,
    String? type,
    bool? isSent,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (dueAt != null) body['due_at'] = dueAt.toIso8601String();
      if (type != null) body['type'] = type;
      if (isSent != null) body['is_sent'] = isSent;

      print('🔔 Actualizando recordatorio $id con datos: $body');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/reminders/$id',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      print('🔔 Respuesta del backend: ${response.data}');
      return Reminder.fromJson(response.data!);
    } catch (e) {
      print('🔔 ❌ Error al actualizar recordatorio: $e');
      rethrow;
    }
  }

  Future<Reminder> completeReminder(String id) async {
    try {
      // Marcar como completado actualizando is_completed
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/reminders/$id',
        body: {'is_completed': true},
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      print('🔔 Recordatorio $id marcado como completado');
      return Reminder.fromJson(response.data!);
    } catch (e) {
      print('🔔 ❌ Error al completar recordatorio: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final response = await _apiClient.delete(
        '/reminders/$id',
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
