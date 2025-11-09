import '../providers/pet_provider.dart';
import '../utils/api_exceptions.dart';
import 'api_client.dart';

class PetService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Pet>> getPets() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/pets',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> petsData;
      if (response.data is List) {
        petsData = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final dataMap = response.data as Map<String, dynamic>;
        petsData = (dataMap['pets'] ?? dataMap['data'] ?? []) as List<dynamic>;
      } else {
        petsData = [];
      }

      if (petsData.isEmpty) return [];

      return petsData
          .map((json) => Pet.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Pet> getPetById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/pets/$id',
        requiresAuth: true,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return Pet.fromMap(response.data!);
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

      print('🐕 Creando mascota con datos: $body');

      final response = await _apiClient.post<Map<String, dynamic>>(
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

      print('🐕 Respuesta del backend: ${response.data}');
      return Pet.fromMap(response.data!);
    } catch (e) {
      print('🐕 ❌ Error al crear mascota: $e');
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
      if (name != null) body['name'] = name;
      if (breed != null) body['breed'] = breed;
      if (ageMonths != null) body['age_months'] = ageMonths;
      if (weightKg != null) body['weight_kg'] = weightKg;
      if (photoUrl != null) body['photo_url'] = photoUrl;
      if (medicalNotes != null) body['medical_notes'] = medicalNotes;
      if (vaccinationStatus != null)
        body['vaccination_status'] = vaccinationStatus;

      print('🐕 Actualizando mascota $id con datos: $body');

      final response = await _apiClient.put<Map<String, dynamic>>(
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

      print('🐕 Respuesta del backend: ${response.data}');
      return Pet.fromMap(response.data!);
    } catch (e) {
      print('🐕 ❌ Error al actualizar mascota: $e');
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
