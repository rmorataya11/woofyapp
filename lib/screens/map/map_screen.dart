import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../config/theme_utils.dart';
import '../../providers/clinic_provider.dart';
import '../../models/clinic_model.dart';
import '../../services/clinic_service.dart';
import '../../services/profile_service.dart';
import '../../utils/api_exceptions.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Clinic> _allClinics = []; // Todas las clínicas cargadas
  List<Clinic> _filteredClinics = []; // Clínicas filtradas
  String _selectedFilter = 'all';
  String _selectedSort = 'rating';

  GoogleMapController? _mapController;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final ProfileService _profileService = ProfileService();
  final ClinicService _clinicService = ClinicService();

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
    super.dispose();
  }

  /// Obtener la ubicación del usuario desde el backend
  Future<void> _getUserLocation() async {
    try {
      debugPrint('📍 Obteniendo ubicación del usuario desde el backend...');

      // Obtener coordenadas del backend
      final locationData = await _profileService.getUserLocation();
      final lat = locationData['latitude']!;
      final lng = locationData['longitude']!;

      debugPrint('📍 Ubicación obtenida del backend: $lat, $lng');

      setState(() {
        _userLocation = LatLng(lat, lng);
      });

      // Mover la cámara a la ubicación del usuario
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
        );
      }

      // Cargar todas las clínicas de la BD
      _loadAllClinics(lat, lng);
    } catch (e) {
      debugPrint('❌ Error obteniendo ubicación del backend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Cargar todas las clínicas guardadas en la BD
  Future<void> _loadAllClinics(double userLat, double userLng) async {
    try {
      debugPrint('🔍 Cargando todas las clínicas de la BD...');

      // Usar el servicio para obtener todas las clínicas
      final clinics = await _clinicService.getClinics();

      debugPrint('🏥 Clínicas obtenidas de la BD: ${clinics.length}');

      Set<Marker> loadedMarkers = {};
      List<Clinic> loadedClinics = [];

      for (var clinic in clinics) {
        try {
          // Verificar que la clínica tenga coordenadas
          if (clinic.latitude == null || clinic.longitude == null) {
            debugPrint('⚠️ Clínica sin coordenadas: ${clinic.name}');
            continue;
          }

          final lat = clinic.latitude!;
          final lng = clinic.longitude!;

          loadedClinics.add(clinic);

          // Crear marcador
          loadedMarkers.add(
            Marker(
              markerId: MarkerId(clinic.id),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: clinic.name,
                snippet: clinic.address,
              ),
              onTap: () {
                if (_userLocation != null) {
                  _createRoute(_userLocation!, LatLng(lat, lng));
                }
              },
            ),
          );
        } catch (e) {
          debugPrint('❌ Error procesando clínica: $e');
          continue;
        }
      }

      debugPrint('✅ Clínicas procesadas: ${loadedClinics.length}');

      setState(() {
        _markers = loadedMarkers;
        _allClinics = loadedClinics; // Guardar todas las clínicas
      });

      // Aplicar filtros y ordenamiento
      _filterClinics();

      // Mover la cámara para mostrar la ubicación del usuario
      if (_mapController != null && _userLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_userLocation!, 14),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error cargando clínicas: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar clínicas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createRoute(LatLng start, LatLng end) async {
    const apiKey =
        'AIzaSyAwrUsw07bJs_G8Dg0IVj6Xz1QHMYkiJPQ'; // tu Google Maps API Key
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
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.pinkAccent,
            width: 5,
          ),
        };
      });
    }
  }

  void _filterClinics() {
    // Usar las clínicas cargadas localmente si están disponibles, sino usar el provider
    final allClinics = _allClinics.isNotEmpty
        ? _allClinics
        : ref.read(clinicProvider).clinics;

    setState(() {
      List<Clinic> filtered = allClinics.where((clinic) {
        bool matchesFilter = true;
        // Solo filtrar por activas cuando se seleccione
        if (_selectedFilter == 'active') {
          matchesFilter = clinic.isActive;
        }

        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          matchesSearch =
              clinic.name.toLowerCase().contains(searchText) ||
              clinic.address.toLowerCase().contains(searchText);
        }

        return matchesFilter && matchesSearch;
      }).toList();

      filtered.sort((a, b) {
        switch (_selectedSort) {
          case 'rating':
            return (b.rating ?? 0.0).compareTo(a.rating ?? 0.0);
          case 'name':
            return a.name.compareTo(b.name);
          default:
            return 0;
        }
      });

      _filteredClinics = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clinicState = ref.watch(clinicProvider);

    if (clinicState.clinics.isNotEmpty && _filteredClinics.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _filterClinics();
      });
    }

    return Scaffold(
      body: Container(
        decoration: ThemeUtils.getBackgroundDecoration(context, ref),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchAndFilters(),
              Expanded(
                child: clinicState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMapOnly(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Veterinarias Cercanas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await ref.read(clinicProvider.notifier).refresh();
              _filterClinics();
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Lista actualizada'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Vista de mapa real'),
                ),
              );
            },
            icon: Icon(Icons.map, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar veterinarias...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterClinics();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            onChanged: (value) => _filterClinics(),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter['id'];
                      });
                      _filterClinics();
                    },
                    label: Text(filter['name']),
                    avatar: Icon(
                      filter['icon'],
                      size: 18,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Ordenar por:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedSort,
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                  _filterClinics();
                },
                items: const [
                  DropdownMenuItem(value: 'distance', child: Text('Distancia')),
                  DropdownMenuItem(
                    value: 'rating',
                    child: Text('Calificación'),
                  ),
                  DropdownMenuItem(
                    value: 'wait_time',
                    child: Text('Tiempo de espera'),
                  ),
                ],
                underline: Container(),
                style: const TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapOnly() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ThemeUtils.getShadowColor(context, ref),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _userLocation == null
                  ? Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Obteniendo tu ubicación...',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _getUserLocation,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        // Asegurar que la cámara esté en la ubicación del usuario
                        if (_userLocation != null) {
                          controller.animateCamera(
                            CameraUpdate.newLatLngZoom(_userLocation!, 14),
                          );
                        }
                      },
                    ),
            ),
          ),
          _buildClinicsList(),
        ],
      ),
    );
  }

  Widget _buildClinicsList() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clínicas Disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (_filteredClinics.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeUtils.getCardColor(context, ref),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No se encontraron clínicas cercanas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._filteredClinics.map((clinic) => _buildClinicCard(clinic)),
        ],
      ),
    );
  }

  Widget _buildClinicCard(Clinic clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF1E88E5),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeUtils.getTextPrimaryColor(context, ref),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFF616161),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              clinic.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeUtils.getTextSecondaryColor(
                                  context,
                                  ref,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${clinic.rating?.toStringAsFixed(1) ?? '0.0'} ⭐',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showContactModal(clinic),
                  icon: const Icon(Icons.email, size: 14),
                  label: const Text(
                    'Contactar',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showContactModal(Clinic clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactModal(clinic: clinic),
    );
  }
}

class _ContactModal extends StatefulWidget {
  final Clinic clinic;

  const _ContactModal({required this.clinic});

  @override
  _ContactModalState createState() => _ContactModalState();
}

class _ContactModalState extends State<_ContactModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ClinicService _clinicService = ClinicService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.email,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contactar Clínica',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        widget.clinic.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tu nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Tu email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Tu teléfono',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Mensaje',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.message),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Enviar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _clinicService.contactClinic(
        clinicId: widget.clinic.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mensaje enviado a ${widget.clinic.name}'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop();
      }
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } on UnauthorizedException {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para contactar clínicas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
