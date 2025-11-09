class Appointment {
  final String id;
  final String userId;
  final String clinicId;
  final String petId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String appointmentDate;
  final String appointmentTime;
  final String serviceType;
  final String? reason;
  final String status;
  final String? notes;
  final bool createdFromRequest;
  final String? requestId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? clinicName;
  final String? clinicAddress;
  final String? clinicPhone;
  final String? petName;
  final String? petBreed;

  Appointment({
    required this.id,
    required this.userId,
    required this.clinicId,
    required this.petId,
    required this.startsAt,
    required this.endsAt,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.serviceType,
    this.reason,
    required this.status,
    this.notes,
    this.createdFromRequest = false,
    this.requestId,
    required this.createdAt,
    required this.updatedAt,
    this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    this.petName,
    this.petBreed,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final clinic = json['clinic'] as Map<String, dynamic>?;
    final pet = json['pet'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;

    return Appointment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clinicId: json['clinic_id'] as String,
      petId: json['pet_id'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      appointmentDate: json['appointment_date'] as String? ?? '',
      appointmentTime: json['appointment_time'] as String? ?? '',
      serviceType:
          json['service_type'] as String? ??
          service?['category'] as String? ??
          '',
      reason: json['reason'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdFromRequest: json['created_from_request'] as bool? ?? false,
      requestId: json['request_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      clinicName: clinic?['name'] as String?,
      clinicAddress: clinic?['address'] as String?,
      clinicPhone: clinic?['phone'] as String?,
      petName: pet?['name'] as String?,
      petBreed: pet?['breed'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'clinic_id': clinicId,
      'pet_id': petId,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'service_type': serviceType,
      'reason': reason,
      'status': status,
      'notes': notes,
      'created_from_request': createdFromRequest,
      'request_id': requestId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? userId,
    String? clinicId,
    String? petId,
    DateTime? startsAt,
    DateTime? endsAt,
    String? appointmentDate,
    String? appointmentTime,
    String? serviceType,
    String? reason,
    String? status,
    String? notes,
    bool? createdFromRequest,
    String? requestId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? clinicName,
    String? clinicAddress,
    String? clinicPhone,
    String? petName,
    String? petBreed,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clinicId: clinicId ?? this.clinicId,
      petId: petId ?? this.petId,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      serviceType: serviceType ?? this.serviceType,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdFromRequest: createdFromRequest ?? this.createdFromRequest,
      requestId: requestId ?? this.requestId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      petName: petName ?? this.petName,
      petBreed: petBreed ?? this.petBreed,
    );
  }

  bool get isUrgent {
    final now = DateTime.now();
    final difference = startsAt.difference(now);
    return difference.inHours < 24 && difference.inHours > 0;
  }

  bool get isToday {
    final now = DateTime.now();
    return startsAt.year == now.year &&
        startsAt.month == now.month &&
        startsAt.day == now.day;
  }

  bool get isPast {
    return startsAt.isBefore(DateTime.now());
  }

  @override
  String toString() =>
      'Appointment(id: $id, petName: $petName, clinic: $clinicName, date: $appointmentDate)';
}

class AppointmentRequest {
  final String id;
  final String userId;
  final String clinicId;
  final String petId;
  final String preferredDate;
  final String preferredTime;
  final String serviceType;
  final String reason;
  final String? notes;
  final String status;
  final String? finalDate;
  final String? finalTime;
  final DateTime? confirmedAt;
  final String? confirmationNotes;
  final String requestType;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? clinicName;
  final String? clinicPhone;
  final String? clinicEmail;
  final String? clinicAddress;
  final String? petName;
  final String? petBreed;
  final int? petAge;

  AppointmentRequest({
    required this.id,
    required this.userId,
    required this.clinicId,
    required this.petId,
    required this.preferredDate,
    required this.preferredTime,
    required this.serviceType,
    required this.reason,
    this.notes,
    required this.status,
    this.finalDate,
    this.finalTime,
    this.confirmedAt,
    this.confirmationNotes,
    required this.requestType,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.clinicName,
    this.clinicPhone,
    this.clinicEmail,
    this.clinicAddress,
    this.petName,
    this.petBreed,
    this.petAge,
  });

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    return AppointmentRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clinicId: json['clinic_id'] as String,
      petId: json['pet_id'] as String,
      preferredDate: json['preferred_date'] as String,
      preferredTime: json['preferred_time'] as String,
      serviceType: json['service_type'] as String,
      reason: json['reason'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      finalDate: json['final_date'] as String?,
      finalTime: json['final_time'] as String?,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      confirmationNotes: json['confirmation_notes'] as String?,
      requestType: json['request_type'] as String? ?? 'user_initiated',
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      clinicName: json['clinic']?['name'] as String?,
      clinicPhone: json['clinic']?['phone'] as String?,
      clinicEmail: json['clinic']?['email'] as String?,
      clinicAddress: json['clinic']?['address'] as String?,
      petName: json['pet']?['name'] as String?,
      petBreed: json['pet']?['breed'] as String?,
      petAge: json['pet']?['age'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'clinic_id': clinicId,
      'pet_id': petId,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'service_type': serviceType,
      'reason': reason,
      'notes': notes,
      'status': status,
      'final_date': finalDate,
      'final_time': finalTime,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'confirmation_notes': confirmationNotes,
      'request_type': requestType,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static const String statusPending = 'pending_confirmation';
  static const String statusConfirmed = 'confirmed_by_clinic';
  static const String statusCancelled = 'cancelled';
  static const String statusRejected = 'rejected';

  bool get isPending => status == statusPending;

  bool get isConfirmed => status == statusConfirmed;

  bool get isCancelled => status == statusCancelled;

  @override
  String toString() =>
      'AppointmentRequest(id: $id, clinic: $clinicName, pet: $petName, status: $status)';
}
