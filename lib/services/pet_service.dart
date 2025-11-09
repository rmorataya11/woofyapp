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

      final petsData = response.data!['pets'] as List<dynamic>?;
      if (petsData == null) return [];

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
    required int age,
    required String gender,
    required double weight,
    required String color,
    String? medicalNotes,
    String? vaccinationStatus,
  }) async {
    try {
      final body = {
        'name': name,
        'breed': breed,
        'age_months': age * 12,
        'gender': gender,
        'weight_kg': weight,
        'color': color.isNotEmpty ? color : null,
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
    int? age,
    String? gender,
    double? weight,
    String? color,
    String? medicalNotes,
    String? vaccinationStatus,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (breed != null) body['breed'] = breed;
      if (age != null) body['age_months'] = age * 12;
      if (gender != null) body['gender'] = gender;
      if (weight != null) body['weight_kg'] = weight;
      if (color != null) body['color'] = color.isNotEmpty ? color : null;
      if (medicalNotes != null) body['medical_notes'] = medicalNotes;
      if (vaccinationStatus != null) {
        body['vaccination_status'] = vaccinationStatus;
      }

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
