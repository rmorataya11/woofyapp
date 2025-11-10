import '../models/pet_model.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class PetService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Pet>> getPets() async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/pets',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final petsData = response.data as List<dynamic>? ?? [];

      return petsData
          .map((json) => Pet.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Pet> getPetById(String id) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/pets/$id',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Pet.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Pet> createPet({
    required String name,
    required String breed,
    required int ageMonths,
    required double weightKg,
    String? photoUrl,
    String? medicalNotes,
    String? vaccinationStatus,
  }) async {
    try {
      final body = {
        'name': name,
        'breed': breed,
        'age_months': ageMonths,
        'weight_kg': weightKg,
        if (photoUrl != null) 'photo_url': photoUrl,
        'medical_notes': medicalNotes ?? '',
        'vaccination_status': vaccinationStatus ?? 'unknown',
      };

      final response = await _apiClient.post<dynamic>(
        '/pets',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Pet.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Pet> updatePet({
    required String id,
    String? name,
    String? breed,
    int? ageMonths,
    double? weightKg,
    String? photoUrl,
    String? medicalNotes,
    String? vaccinationStatus,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) {
        body['name'] = name;
      }
      if (breed != null) {
        body['breed'] = breed;
      }
      if (ageMonths != null) {
        body['age_months'] = ageMonths;
      }
      if (weightKg != null) {
        body['weight_kg'] = weightKg;
      }
      if (photoUrl != null) {
        body['photo_url'] = photoUrl;
      }
      if (medicalNotes != null) {
        body['medical_notes'] = medicalNotes;
      }
      if (vaccinationStatus != null) {
        body['vaccination_status'] = vaccinationStatus;
      }

      final response = await _apiClient.put<dynamic>(
        '/pets/$id',
        body: body,
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Pet.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePet(String id) async {
    try {
      final response = await _apiClient.delete('/pets/$id', requiresAuth: true);

      if (!response.success) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
