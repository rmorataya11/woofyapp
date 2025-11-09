class AiMessage {
  final String id;
  final String conversationId;
  final String content;
  final String role;
  final DateTime createdAt;

  AiMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.role,
    required this.createdAt,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'content': content,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  @override
  String toString() =>
      'AiMessage(id: $id, role: $role, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
}

class AiConversation {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AiMessage> messages;

  AiConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  factory AiConversation.fromJson(Map<String, dynamic> json) {
    final messagesData = json['messages'] as List<dynamic>?;
    final messages = messagesData != null
        ? messagesData
              .map((msg) => AiMessage.fromJson(msg as Map<String, dynamic>))
              .toList()
        : <AiMessage>[];

    return AiConversation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }

  AiConversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AiMessage>? messages,
  }) {
    return AiConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  @override
  String toString() => 'AiConversation(id: $id, title: $title)';
}
