import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteCreator {
  static const String apiKey = 'AIzaSyAocTk8Qn1rcNRG7hX-SsJP41k9a5AIp5w';

  /// Crear ruta entre dos puntos
  static Future<Set<Polyline>> createRoute(LatLng start, LatLng end) async {
    try {
      PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(start.latitude, start.longitude),
          destination: PointLatLng(end.latitude, end.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        return {
          Polyline(
            polylineId: const PolylineId('route'),
            color: const Color(0xFF1E88E5),
            width: 5,
            points: polylineCoordinates,
          ),
        };
      }

      return {};
    } catch (e) {
      debugPrint('Error creating route: $e');
      return {};
    }
  }

  /// Limpiar rutas
  static Set<Polyline> clearRoutes() {
    return {};
  }
}
