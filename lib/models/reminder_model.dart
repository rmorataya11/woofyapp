class Reminder {
  final String id;
  final String userId;
  final String? petId;
  final String title;
  final String? description;
  final DateTime reminderDate;
  final String reminderTime;
  final String type;
  final bool isCompleted;
  final bool isRecurring;
  final String? frequency;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? petName;
  final String? petBreed;

  Reminder({
    required this.id,
    required this.userId,
    this.petId,
    required this.title,
    this.description,
    required this.reminderDate,
    required this.reminderTime,
    required this.type,
    this.isCompleted = false,
    this.isRecurring = false,
    this.frequency,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.petName,
    this.petBreed,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      petId: json['pet_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      reminderDate: DateTime.parse(json['reminder_date'] as String),
      reminderTime: json['reminder_time'] as String,
      type: json['type'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      isRecurring: json['is_recurring'] as bool? ?? false,
      frequency: json['frequency'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      petName: json['pet_name'] as String?,
      petBreed: json['pet_breed'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'title': title,
      'description': description,
      'reminder_date': reminderDate.toIso8601String(),
      'reminder_time': reminderTime,
      'type': type,
      'is_completed': isCompleted,
      'is_recurring': isRecurring,
      'frequency': frequency,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? petId,
    String? title,
    String? description,
    DateTime? reminderDate,
    String? reminderTime,
    String? type,
    bool? isCompleted,
    bool? isRecurring,
    String? frequency,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? petName,
    String? petBreed,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderTime: reminderTime ?? this.reminderTime,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      petName: petName ?? this.petName,
      petBreed: petBreed ?? this.petBreed,
    );
  }

  static const String typeMedication = 'medication';
  static const String typeExercise = 'exercise';
  static const String typeGrooming = 'grooming';
  static const String typeFeeding = 'feeding';
  static const String typeVaccine = 'vaccine';
  static const String typeCheckup = 'checkup';
  static const String typeOther = 'other';

  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyMonthly = 'monthly';
  static const String frequencyYearly = 'yearly';

  bool get isToday {
    final now = DateTime.now();
    return reminderDate.year == now.year &&
        reminderDate.month == now.month &&
        reminderDate.day == now.day;
  }

  bool get isPast {
    return reminderDate.isBefore(DateTime.now()) && !isCompleted;
  }

  bool get isUrgent {
    return isToday && !isCompleted;
  }

  @override
  String toString() =>
      'Reminder(id: $id, title: $title, pet: $petName, date: ${reminderDate.toIso8601String()})';
}
