class Clinic {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final double? rating;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? googlePlaceId;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.rating,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.googlePlaceId,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      googlePlaceId: json['google_place_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'rating': rating,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'google_place_id': googlePlaceId,
    };
  }

  Clinic copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    double? rating,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? googlePlaceId,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
    );
  }

  @override
  String toString() => 'Clinic(id: $id, name: $name, address: $address)';
}

class ClinicServiceModel {
  final String id;
  final String clinicId;
  final String name;
  final String? description;
  final double? price;
  final int? duration;
  final bool isActive;

  ClinicServiceModel({
    required this.id,
    required this.clinicId,
    required this.name,
    this.description,
    this.price,
    this.duration,
    required this.isActive,
  });

  factory ClinicServiceModel.fromJson(Map<String, dynamic> json) {
    return ClinicServiceModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      duration: json['duration'] as int?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'is_active': isActive,
    };
  }
}

class ClinicHours {
  final String clinicId;
  final Map<String, List<TimeSlot>> schedule;

  ClinicHours({required this.clinicId, required this.schedule});

  factory ClinicHours.fromJson(Map<String, dynamic> json) {
    final scheduleData = json['schedule'] as Map<String, dynamic>? ?? {};
    final schedule = <String, List<TimeSlot>>{};

    scheduleData.forEach((day, slots) {
      schedule[day] = (slots as List<dynamic>)
          .map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
          .toList();
    });

    return ClinicHours(
      clinicId: json['clinic_id'] as String,
      schedule: schedule,
    );
  }
}

class TimeSlot {
  final String start;
  final String end;

  TimeSlot({required this.start, required this.end});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(start: json['start'] as String, end: json['end'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end};
  }
}
