import '../models/reminder_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class ReminderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Reminder>> getReminders({
    String? petId,
    bool? isCompleted,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (petId != null) queryParams['pet_id'] = petId;
      if (isCompleted != null) {
        queryParams['is_completed'] = isCompleted.toString();
      }

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

      final remindersData = response.data!['reminders'] as List<dynamic>?;
      if (remindersData == null) return [];

      return remindersData
          .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
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
    String? petId,
    required String title,
    String? description,
    required DateTime reminderDate,
    required String reminderTime,
    required String type,
    bool isRecurring = false,
    String? frequency,
  }) async {
    try {
      final body = {
        if (petId != null) 'pet_id': petId,
        'title': title,
        if (description != null) 'description': description,
        'reminder_date': reminderDate.toIso8601String().split('T')[0],
        'reminder_time': reminderTime,
        'type': type,
        'is_recurring': isRecurring,
        if (frequency != null) 'frequency': frequency,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/reminders',
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
    String? petId,
    String? title,
    String? description,
    DateTime? reminderDate,
    String? reminderTime,
    String? type,
    bool? isRecurring,
    String? frequency,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (petId != null) body['pet_id'] = petId;
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (reminderDate != null) {
        body['reminder_date'] = reminderDate.toIso8601String().split('T')[0];
      }
      if (reminderTime != null) body['reminder_time'] = reminderTime;
      if (type != null) body['type'] = type;
      if (isRecurring != null) body['is_recurring'] = isRecurring;
      if (frequency != null) body['frequency'] = frequency;

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

      return Reminder.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Reminder> completeReminder(String id) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/reminders/$id/complete',
        body: {},
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
