import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_chat_model.dart';
import '../services/ai_chat_service.dart';
import 'auth_provider.dart';

class AiChatState {
  final List<AiConversation> conversations;
  final AiConversation? currentConversation;
  final bool isLoading;
  final bool isSendingMessage;
  final String? errorMessage;

  AiChatState({
    required this.conversations,
    this.currentConversation,
    this.isLoading = false,
    this.isSendingMessage = false,
    this.errorMessage,
  });

  AiChatState copyWith({
    List<AiConversation>? conversations,
    AiConversation? currentConversation,
    bool? isLoading,
    bool? isSendingMessage,
    String? errorMessage,
    bool clearCurrentConversation = false,
  }) {
    return AiChatState(
      conversations: conversations ?? this.conversations,
      currentConversation: clearCurrentConversation
          ? null
          : currentConversation ?? this.currentConversation,
      isLoading: isLoading ?? this.isLoading,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      errorMessage: errorMessage,
    );
  }

  factory AiChatState.initial() {
    return AiChatState(conversations: []);
  }

  factory AiChatState.loading() {
    return AiChatState(conversations: [], isLoading: true);
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AiChatService _aiChatService = AiChatService();
  final Ref _ref;

  AiChatNotifier(this._ref) : super(AiChatState.initial()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true);

    try {
      final conversations = await _aiChatService.getConversations();
      state = AiChatState(conversations: conversations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> loadConversation(String conversationId) async {
    state = state.copyWith(isLoading: true);

    try {
      final conversation = await _aiChatService.getConversation(conversationId);
      state = state.copyWith(
        currentConversation: conversation,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<AiConversation?> createConversation({String? title}) async {
    state = state.copyWith(isLoading: true);

    try {
      // Obtener el user_id del authProvider
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final newConversation = await _aiChatService.createConversation(
        userId: user.id,
        title: title,
      );

      state = AiChatState(
        conversations: [newConversation, ...state.conversations],
        currentConversation: newConversation,
        isLoading: false,
      );

      return newConversation;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    if (state.currentConversation == null ||
        state.currentConversation!.id != conversationId) {
      return false;
    }

    final userMessage = AiMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      content: content,
      role: 'user',
      createdAt: DateTime.now(),
    );

    final updatedConversation = state.currentConversation!.copyWith(
      messages: [...state.currentConversation!.messages, userMessage],
    );

    state = state.copyWith(
      currentConversation: updatedConversation,
      isSendingMessage: true,
    );

    try {
      final result = await _aiChatService.sendMessage(
        conversationId: conversationId,
        content: content,
      );

      final userMsg = AiMessage.fromJson(
        result['user_message'] as Map<String, dynamic>,
      );
      final assistantMsg = AiMessage.fromJson(
        result['assistant_message'] as Map<String, dynamic>,
      );

      final messages = state.currentConversation!.messages
          .where((msg) => !msg.id.startsWith('temp-'))
          .toList();
      messages.addAll([userMsg, assistantMsg]);

      final finalConversation = state.currentConversation!.copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
      );

      final updatedConversations = state.conversations
          .map((conv) => conv.id == conversationId ? finalConversation : conv)
          .toList();

      state = AiChatState(
        conversations: updatedConversations,
        currentConversation: finalConversation,
        isSendingMessage: false,
      );

      return true;
    } catch (e) {
      final revertedConversation = state.currentConversation!.copyWith(
        messages: state.currentConversation!.messages
            .where((msg) => !msg.id.startsWith('temp-'))
            .toList(),
      );

      state = state.copyWith(
        currentConversation: revertedConversation,
        isSendingMessage: false,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _aiChatService.deleteConversation(conversationId);

      final updatedConversations = state.conversations
          .where((conv) => conv.id != conversationId)
          .toList();

      final clearCurrent = state.currentConversation?.id == conversationId;

      state = AiChatState(
        conversations: updatedConversations,
        currentConversation: clearCurrent ? null : state.currentConversation,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void setCurrentConversation(AiConversation? conversation) {
    state = state.copyWith(
      currentConversation: conversation,
      clearCurrentConversation: conversation == null,
    );
  }

  Future<void> refresh() async {
    await loadConversations();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((
  ref,
) {
  return AiChatNotifier(ref);
});

final currentConversationProvider = Provider<AiConversation?>((ref) {
  final state = ref.watch(aiChatProvider);
  return state.currentConversation;
});
