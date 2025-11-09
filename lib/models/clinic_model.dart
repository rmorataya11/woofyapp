class Clinic {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final double? rating;
  final double? distance;
  final int? waitTime;
  final bool isOpen;
  final bool isActive;
  final List<String> specialties;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.rating,
    this.distance,
    this.waitTime,
    required this.isOpen,
    required this.isActive,
    required this.specialties,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      waitTime: json['wait_time'] as int?,
      isOpen: json['is_open'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      specialties:
          (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'rating': rating,
      'distance': distance,
      'wait_time': waitTime,
      'is_open': isOpen,
      'is_active': isActive,
      'specialties': specialties,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Clinic copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    double? rating,
    double? distance,
    int? waitTime,
    bool? isOpen,
    bool? isActive,
    List<String>? specialties,
    String? imageUrl,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      waitTime: waitTime ?? this.waitTime,
      isOpen: isOpen ?? this.isOpen,
      isActive: isActive ?? this.isActive,
      specialties: specialties ?? this.specialties,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
