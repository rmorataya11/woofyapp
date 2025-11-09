import '../models/ai_chat_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class AiChatService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AiConversation>> getConversations() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/ai-chat/conversations',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final conversationsData =
          response.data!['conversations'] as List<dynamic>?;
      if (conversationsData == null) return [];

      return conversationsData
          .map((json) => AiConversation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AiConversation> getConversation(String conversationId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/ai-chat/conversations/$conversationId',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return AiConversation.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<AiConversation> createConversation({String? title}) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/ai-chat/conversations',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return AiConversation.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final body = {'content': content};

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/ai-chat/conversations/$conversationId/messages',
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

  Future<void> deleteConversation(String conversationId) async {
    try {
      final response = await _apiClient.delete(
        '/ai-chat/conversations/$conversationId',
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
