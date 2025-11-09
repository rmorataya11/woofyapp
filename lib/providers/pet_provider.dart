import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pet_service.dart';
import '../utils/api_exceptions.dart';

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
      lastVetVisit: DateTime.parse(
        map['last_vet_visit'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class PetNotifier extends StateNotifier<List<Pet>> {
  final PetService _petService = PetService();

  PetNotifier() : super([]) {
    loadPets();
  }

  Future<void> loadPets() async {
    try {
      final pets = await _petService.getPets();
      state = pets;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> addPet(Pet pet) async {
    try {
      final newPet = await _petService.createPet(
        name: pet.name,
        breed: pet.breed,
        age: pet.age,
        gender: pet.gender,
        weight: pet.weight,
        color: pet.color,
        medicalNotes: pet.medicalNotes,
        vaccinationStatus: pet.vaccinationStatus,
      );

      state = [...state, newPet];
      return true;
    } on ValidationException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> updatePet(Pet updatedPet) async {
    try {
      final pet = await _petService.updatePet(
        id: updatedPet.id,
        name: updatedPet.name,
        breed: updatedPet.breed,
        age: updatedPet.age,
        gender: updatedPet.gender,
        weight: updatedPet.weight,
        color: updatedPet.color,
        medicalNotes: updatedPet.medicalNotes,
        vaccinationStatus: updatedPet.vaccinationStatus,
      );

      state = state.map((p) => p.id == pet.id ? pet : p).toList();
      return true;
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> deletePet(String petId) async {
    try {
      await _petService.deletePet(petId);
      state = state.where((pet) => pet.id != petId).toList();
      return true;
    } on NotFoundException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Pet? getPetById(String id) {
    try {
      return state.firstWhere((pet) => pet.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Pet> getPetsByVaccinationStatus(String status) {
    return state.where((pet) => pet.vaccinationStatus == status).toList();
  }

  Future<void> refresh() async {
    await loadPets();
  }
}

final petNotifierProvider = StateNotifierProvider<PetNotifier, List<Pet>>((
  ref,
) {
  return PetNotifier();
});

final petByIdProvider = Provider.family<Pet?, String>((ref, id) {
  final pets = ref.watch(petNotifierProvider);
  return pets.where((pet) => pet.id == id).firstOrNull;
});
