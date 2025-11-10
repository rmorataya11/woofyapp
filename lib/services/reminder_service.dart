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

      final response = await _apiClient.get<dynamic>(
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

      final remindersData = response.data as List<dynamic>? ?? [];

      return remindersData
          .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Reminder> getReminderById(String id) async {
    try {
      final response = await _apiClient.get<dynamic>(
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

      final response = await _apiClient.post<dynamic>(
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

      return Reminder.fromJson(response.data!);
    } catch (e) {
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

      final response = await _apiClient.put<dynamic>(
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

      return Reminder.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Reminder> completeReminder(String id) async {
    try {
      final response = await _apiClient.put<dynamic>(
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

      return Reminder.fromJson(response.data!);
    } catch (e) {
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
