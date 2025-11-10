class Pet {
  final String id;
  final String name;
  final String breed;
  final int ageMonths;
  final double weightKg;
  final String? photoUrl;
  final String medicalNotes;
  final String vaccinationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageMonths,
    required this.weightKg,
    this.photoUrl,
    required this.medicalNotes,
    required this.vaccinationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    int? ageMonths,
    double? weightKg,
    String? photoUrl,
    String? medicalNotes,
    String? vaccinationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      ageMonths: ageMonths ?? this.ageMonths,
      weightKg: weightKg ?? this.weightKg,
      photoUrl: photoUrl ?? this.photoUrl,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age_months': ageMonths,
      'weight_kg': weightKg,
      'photo_url': photoUrl,
      'medical_notes': medicalNotes,
      'vaccination_status': vaccinationStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      ageMonths: json['age_months'] ?? 0,
      weightKg: (json['weight_kg'] ?? 0.0).toDouble(),
      photoUrl: json['photo_url'],
      medicalNotes: json['medical_notes'] ?? '',
      vaccinationStatus: json['vaccination_status'] ?? 'unknown',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  int get ageYears => (ageMonths / 12).floor();
  int get remainingMonths => ageMonths % 12;

  @override
  String toString() => 'Pet(id: $id, name: $name, breed: $breed)';
}
