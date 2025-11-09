class Reminder {
  final String id;
  final String petId;
  final String title;
  final String? description;
  final DateTime dueAt;
  final String type;
  final bool isSent;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? petName;
  final String? petBreed;

  Reminder({
    required this.id,
    required this.petId,
    required this.title,
    this.description,
    required this.dueAt,
    required this.type,
    this.isSent = false,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.petName,
    this.petBreed,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final pet = json['pet'] as Map<String, dynamic>?;

    return Reminder(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueAt: DateTime.parse(json['due_at'] as String),
      type: json['type'] as String,
      isSent: json['is_sent'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      petName: pet?['name'] as String?,
      petBreed: pet?['breed'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'title': title,
      'description': description,
      'due_at': dueAt.toIso8601String(),
      'type': type,
      'is_sent': isSent,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Reminder copyWith({
    String? id,
    String? petId,
    String? title,
    String? description,
    DateTime? dueAt,
    String? type,
    bool? isSent,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? petName,
    String? petBreed,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      type: type ?? this.type,
      isSent: isSent ?? this.isSent,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      petName: petName ?? this.petName,
      petBreed: petBreed ?? this.petBreed,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return dueAt.year == now.year &&
        dueAt.month == now.month &&
        dueAt.day == now.day;
  }

  bool get isPast {
    return dueAt.isBefore(DateTime.now()) && !isCompleted;
  }

  bool get isUrgent {
    return isToday && !isCompleted;
  }

  @override
  String toString() =>
      'Reminder(id: $id, title: $title, pet: $petName, date: ${dueAt.toIso8601String()})';
}
