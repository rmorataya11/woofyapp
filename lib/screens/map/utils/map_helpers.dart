import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/clinic_model.dart';

class MapHelpers {
  /// Calcular distancia entre dos coordenadas usando la fórmula de Haversine
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Radio de la Tierra en km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Crear marcadores para las clínicas
  static Set<Marker> createClinicMarkers(
    List<Clinic> clinics,
    Function(Clinic) onTap,
  ) {
    return clinics
        .where((clinic) {
          return clinic.latitude != null && clinic.longitude != null;
        })
        .map((clinic) {
          return Marker(
            markerId: MarkerId(clinic.id),
            position: LatLng(clinic.latitude!, clinic.longitude!),
            infoWindow: InfoWindow(title: clinic.name, snippet: clinic.address),
            onTap: () => onTap(clinic),
          );
        })
        .toSet();
  }

  /// Ordenar clínicas por distancia
  static List<Clinic> sortClinicsByDistance(
    List<Clinic> clinics,
    double userLat,
    double userLng,
  ) {
    final clinicsWithDistance = clinics.map((clinic) {
      if (clinic.latitude == null || clinic.longitude == null) {
        return MapEntry(clinic, double.infinity);
      }
      final distance = calculateDistance(
        userLat,
        userLng,
        clinic.latitude!,
        clinic.longitude!,
      );
      return MapEntry(clinic, distance);
    }).toList();

    clinicsWithDistance.sort((a, b) => a.value.compareTo(b.value));
    return clinicsWithDistance.map((e) => e.key).toList();
  }

  /// Ordenar clínicas por rating
  static List<Clinic> sortClinicsByRating(List<Clinic> clinics) {
    final sorted = List<Clinic>.from(clinics);
    sorted.sort((a, b) {
      final ratingA = a.rating ?? 0;
      final ratingB = b.rating ?? 0;
      return ratingB.compareTo(ratingA);
    });
    return sorted;
  }

  /// Filtrar clínicas por búsqueda
  static List<Clinic> filterClinicsBySearch(
    List<Clinic> clinics,
    String query,
  ) {
    if (query.isEmpty) return clinics;

    final lowerQuery = query.toLowerCase();
    return clinics.where((clinic) {
      return clinic.name.toLowerCase().contains(lowerQuery) ||
          clinic.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filtrar clínicas por estado
  static List<Clinic> filterClinicsByStatus(
    List<Clinic> clinics,
    String filter,
  ) {
    if (filter == 'all') return clinics;
    if (filter == 'active') {
      return clinics.where((clinic) => clinic.isActive).toList();
    }
    return clinics;
  }

  /// Formatear distancia para mostrar
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }
}
