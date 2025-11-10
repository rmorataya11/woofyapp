import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pet_service.dart';
import '../utils/api_exceptions.dart';

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

  Map<String, dynamic> toMap() {
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

  static Pet fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      ageMonths: map['age_months'] ?? 0,
      weightKg: (map['weight_kg'] ?? 0.0).toDouble(),
      photoUrl: map['photo_url'],
      medicalNotes: map['medical_notes'] ?? '',
      vaccinationStatus: map['vaccination_status'] ?? 'unknown',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  int get ageYears => (ageMonths / 12).floor();
  int get remainingMonths => ageMonths % 12;
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
        ageMonths: pet.ageMonths,
        weightKg: pet.weightKg,
        photoUrl: pet.photoUrl,
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
        ageMonths: updatedPet.ageMonths,
        weightKg: updatedPet.weightKg,
        photoUrl: updatedPet.photoUrl,
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
