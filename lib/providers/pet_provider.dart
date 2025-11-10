import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';
import '../utils/api_exceptions.dart';

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
