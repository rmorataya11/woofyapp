import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme_utils.dart';
import '../../providers/clinic_provider.dart';
import '../../models/clinic_model.dart';
import '../../services/profile_service.dart';
import 'widgets/map_header.dart';
import 'widgets/map_search_bar.dart';
import 'widgets/map_filters.dart';
import 'widgets/clinics_list.dart';
import 'widgets/contact_modal.dart';
import 'utils/map_helpers.dart';
import 'utils/route_creator.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Clinic> _filteredClinics = [];
  String _selectedFilter = 'all';
  String _selectedSort = 'rating';

  GoogleMapController? _mapController;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final ProfileService _profileService = ProfileService();

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'name': 'Todas', 'icon': Icons.list},
    {'id': 'active', 'name': 'Activas', 'icon': Icons.check_circle},
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Obtener ubicación del usuario y cargar clínicas
  Future<void> _getUserLocation() async {
    try {
      debugPrint('📍 Obteniendo ubicación del usuario...');

      final locationData = await _profileService.getUserLocation();
      final lat = locationData['latitude']!;
      final lng = locationData['longitude']!;

      debugPrint('📍 Ubicación obtenida: $lat, $lng');

      if (mounted) {
        setState(() {
          _userLocation = LatLng(lat, lng);
        });

        // Mover cámara
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
        );

        // Cargar clínicas
        await ref.read(clinicProvider.notifier).loadClinics();
      }
    } catch (e) {
      debugPrint('⚠️ Error obteniendo ubicación: $e, usando coordenadas por defecto');
      
      // Coordenadas por defecto (San Salvador)
      if (mounted) {
        setState(() {
          _userLocation = const LatLng(13.6929, -89.2182);
        });

        await ref.read(clinicProvider.notifier).loadClinics();
      }
    }
  }

  /// Filtrar y ordenar clínicas
  void _filterAndSortClinics() {
    final clinicState = ref.read(clinicProvider);
    if (clinicState.clinics.isEmpty) return;

    List<Clinic> filtered = clinicState.clinics;

    // Aplicar búsqueda
    if (_searchController.text.isNotEmpty) {
      filtered = MapHelpers.filterClinicsBySearch(
        filtered,
        _searchController.text,
      );
    }

    // Aplicar filtro por estado
    filtered = MapHelpers.filterClinicsByStatus(filtered, _selectedFilter);

    // Aplicar ordenamiento
    if (_userLocation != null && _selectedSort == 'distance') {
      filtered = MapHelpers.sortClinicsByDistance(
        filtered,
        _userLocation!.latitude,
        _userLocation!.longitude,
      );
    } else if (_selectedSort == 'rating') {
      filtered = MapHelpers.sortClinicsByRating(filtered);
    }

    // Actualizar marcadores
    if (_userLocation != null) {
      final markers = MapHelpers.createClinicMarkers(
        filtered,
        (clinic) {
          if (clinic.latitude != null && clinic.longitude != null) {
            _createRoute(
              _userLocation!,
              LatLng(clinic.latitude!, clinic.longitude!),
            );
          }
        },
      );

      setState(() {
        _filteredClinics = filtered;
        _markers = markers;
      });
    } else {
      setState(() {
        _filteredClinics = filtered;
      });
    }
  }

  /// Crear ruta en el mapa
  Future<void> _createRoute(LatLng start, LatLng end) async {
    final polylines = await RouteCreator.createRoute(start, end);
    if (mounted) {
      setState(() {
        _polylines = polylines;
      });
    }
  }

  /// Mostrar modal de contacto
  void _showContactModal(Clinic clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContactModal(clinic: clinic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicState = ref.watch(clinicProvider);

    // Filtrar clínicas cuando cambien
    if (clinicState.clinics.isNotEmpty && _filteredClinics.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _filterAndSortClinics();
      });
    }

    return Scaffold(
      body: Container(
        decoration: ThemeUtils.getBackgroundDecoration(context, ref),
        child: SafeArea(
          child: Column(
            children: [
              const MapHeader(),
              MapSearchBar(
                controller: _searchController,
                onChanged: (_) => _filterAndSortClinics(),
              ),
              MapFilters(
                selectedFilter: _selectedFilter,
                selectedSort: _selectedSort,
                filters: _filters,
                onFilterChanged: (filter) {
                  setState(() => _selectedFilter = filter);
                  _filterAndSortClinics();
                },
                onSortChanged: (sort) {
                  setState(() => _selectedSort = sort);
                  _filterAndSortClinics();
                },
              ),
              Expanded(
                child: clinicState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMapView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Mapa
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _userLocation == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _userLocation!,
                      zoom: 14,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_userLocation != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(_userLocation!, 14),
                        );
                      }
                    },
                  ),
          ),
        ),
        // Lista de clínicas
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            child: ClinicsList(
              clinics: _filteredClinics,
              onClinicContactTap: _showContactModal,
            ),
          ),
        ),
      ],
    );
  }
}
