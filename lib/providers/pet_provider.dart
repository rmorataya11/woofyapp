import 'package:flutter_riverpod/flutter_riverpod.dart';

class Pet {
  final String id;
  final String name;
  final String breed;
  final int age;
  final String gender;
  final double weight;
  final String color;
  final String medicalNotes;
  final String vaccinationStatus;
  final DateTime lastVetVisit;
  final DateTime createdAt;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    required this.color,
    required this.medicalNotes,
    required this.vaccinationStatus,
    required this.lastVetVisit,
    required this.createdAt,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    int? age,
    String? gender,
    double? weight,
    String? color,
    String? medicalNotes,
    String? vaccinationStatus,
    DateTime? lastVetVisit,
    DateTime? createdAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      lastVetVisit: lastVetVisit ?? this.lastVetVisit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'gender': gender,
      'weight': weight,
      'color': color,
      'medical_notes': medicalNotes,
      'vaccination_status': vaccinationStatus,
      'last_vet_visit': lastVetVisit.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Pet fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      color: map['color'] ?? '',
      medicalNotes: map['medical_notes'] ?? '',
      vaccinationStatus: map['vaccination_status'] ?? 'up_to_date',
      lastVetVisit: DateTime.parse(map['last_vet_visit'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PetNotifier extends StateNotifier<List<Pet>> {
  PetNotifier() : super(_getInitialPets()) {
    _loadPets();
  }

  static List<Pet> _getInitialPets() {
    return [
      Pet(
        id: '1',
        name: 'Max',
        breed: 'Golden Retriever',
        age: 3,
        gender: 'male',
        weight: 25.5,
        color: 'Dorado',
        medicalNotes: 'Alérgico al polen, necesita medicamento diario',
        vaccinationStatus: 'up_to_date',
        lastVetVisit: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Pet(
        id: '2',
        name: 'Luna',
        breed: 'Labrador',
        age: 2,
        gender: 'female',
        weight: 22.0,
        color: 'Negro',
        medicalNotes: 'Saludable, necesita ejercicio diario',
        vaccinationStatus: 'up_to_date',
        lastVetVisit: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 730)),
      ),
      Pet(
        id: '3',
        name: 'Rocky',
        breed: 'Pastor Alemán',
        age: 1,
        gender: 'male',
        weight: 18.0,
        color: 'Marrón y Negro',
        medicalNotes: 'Cachorro activo, en proceso de socialización',
        vaccinationStatus: 'in_progress',
        lastVetVisit: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
    ];
  }

  void _loadPets() {
    // En una app real, aquí cargarías desde SharedPreferences o base de datos
    // Por ahora usamos los datos iniciales
  }

  void addPet(Pet pet) {
    print('Adding pet to state: ${pet.name}');
    state = [...state, pet];
    print('Total pets now: ${state.length}');
  }

  void updatePet(Pet updatedPet) {
    state = state.map((pet) => pet.id == updatedPet.id ? updatedPet : pet).toList();
  }

  void deletePet(String petId) {
    state = state.where((pet) => pet.id != petId).toList();
  }

  Pet? getPetById(String id) {
    try {
      return state.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Pet> getPetsByVaccinationStatus(String status) {
    return state.where((pet) => pet.vaccinationStatus == status).toList();
  }
}

// Provider para el PetNotifier
final petNotifierProvider = StateNotifierProvider<PetNotifier, List<Pet>>((ref) {
  return PetNotifier();
});

// Provider para obtener una mascota específica
final petByIdProvider = Provider.family<Pet?, String>((ref, id) {
  final pets = ref.watch(petNotifierProvider);
  return pets.where((pet) => pet.id == id).firstOrNull;
});
