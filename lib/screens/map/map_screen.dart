import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _clinics = [];
  List<Map<String, dynamic>> _filteredClinics = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedSort = 'distance';

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'name': 'Todas', 'icon': Icons.list},
    {'id': 'open', 'name': 'Abiertas', 'icon': Icons.schedule},
    {'id': 'emergency', 'name': 'Emergencias', 'icon': Icons.local_hospital},
    {'id': 'surgery', 'name': 'Cirugía', 'icon': Icons.medical_services},
    {'id': 'cardiology', 'name': 'Cardiología', 'icon': Icons.favorite},
  ];

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    try {
      // Cargar clínicas desde Supabase
      final response = await _supabase
          .from('clinics')
          .select('*')
          .eq('is_active', true)
          .order('rating', ascending: false);

      setState(() {
        _clinics = List<Map<String, dynamic>>.from(response);
        _filteredClinics = List.from(_clinics);
      });
    } catch (e) {
      print('Error cargando clínicas: $e');
      // Datos mock si hay error
      setState(() {
        _clinics = _getMockClinics();
        _filteredClinics = List.from(_clinics);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getMockClinics() {
    return [
      {
        'id': '1',
        'name': 'Clínica Veterinaria Central',
        'address': 'Av. Principal 123, Ciudad',
        'phone': '+1-555-0123',
        'rating': 4.5,
        'distance': 0.8,
        'is_open': true,
        'specialties': ['General', 'Cirugía', 'Emergencias'],
        'wait_time': 15,
        'price_range': '\$50 - \$150',
        'image_url': 'https://via.placeholder.com/300x200',
      },
      {
        'id': '2',
        'name': 'Hospital San Patricio',
        'address': 'Calle Secundaria 456, Ciudad',
        'phone': '+1-555-0456',
        'rating': 4.2,
        'distance': 1.2,
        'is_open': false,
        'specialties': ['Emergencias', 'Cardiología'],
        'wait_time': 30,
        'price_range': '\$80 - \$200',
        'image_url': 'https://via.placeholder.com/300x200',
      },
      {
        'id': '3',
        'name': 'Centro Médico Animal',
        'address': 'Boulevard Norte 789, Ciudad',
        'phone': '+1-555-0789',
        'rating': 4.8,
        'distance': 2.1,
        'is_open': true,
        'specialties': ['General', 'Dermatología', 'Oftalmología'],
        'wait_time': 5,
        'price_range': '\$60 - \$180',
        'image_url': 'https://via.placeholder.com/300x200',
      },
      {
        'id': '4',
        'name': 'Veterinaria 24/7',
        'address': 'Plaza Comercial 321, Ciudad',
        'phone': '+1-555-0321',
        'rating': 4.0,
        'distance': 3.5,
        'is_open': true,
        'specialties': ['Emergencias', 'Cirugía', 'Traumatología'],
        'wait_time': 45,
        'price_range': '\$100 - \$300',
        'image_url': 'https://via.placeholder.com/300x200',
      },
      {
        'id': '5',
        'name': 'Clínica del Perro Feliz',
        'address': 'Calle de las Flores 654, Ciudad',
        'phone': '+1-555-0654',
        'rating': 4.6,
        'distance': 1.8,
        'is_open': true,
        'specialties': ['General', 'Grooming', 'Vacunación'],
        'wait_time': 10,
        'price_range': '\$40 - \$120',
        'image_url': 'https://via.placeholder.com/300x200',
      },
    ];
  }

  void _filterClinics() {
    setState(() {
      _filteredClinics = _clinics.where((clinic) {
        // Filtro por tipo
        bool matchesFilter = true;
        if (_selectedFilter == 'open') {
          matchesFilter = clinic['is_open'] == true;
        } else if (_selectedFilter == 'emergency') {
          matchesFilter = clinic['specialties'].contains('Emergencias');
        } else if (_selectedFilter == 'surgery') {
          matchesFilter = clinic['specialties'].contains('Cirugía');
        } else if (_selectedFilter == 'cardiology') {
          matchesFilter = clinic['specialties'].contains('Cardiología');
        }

        // Filtro por búsqueda
        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          matchesSearch =
              clinic['name'].toLowerCase().contains(searchText) ||
              clinic['address'].toLowerCase().contains(searchText) ||
              clinic['specialties'].any(
                (specialty) => specialty.toLowerCase().contains(searchText),
              );
        }

        return matchesFilter && matchesSearch;
      }).toList();

      // Ordenar resultados
      _filteredClinics.sort((a, b) {
        switch (_selectedSort) {
          case 'distance':
            return a['distance'].compareTo(b['distance']);
          case 'rating':
            return b['rating'].compareTo(a['rating']);
          case 'wait_time':
            return a['wait_time'].compareTo(b['wait_time']);
          default:
            return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchAndFilters(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1E88E5),
                          ),
                        ),
                      )
                    : _buildClinicsList(),
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
          const Icon(Icons.location_on, color: Color(0xFF1E88E5), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Veterinarias Cercanas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implementar vista de mapa real
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Vista de mapa real'),
                ),
              );
            },
            icon: const Icon(Icons.map, color: Color(0xFF1E88E5), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterClinics(),
              decoration: InputDecoration(
                hintText: 'Buscar veterinarias...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E88E5)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterClinics();
                        },
                        icon: const Icon(Icons.clear, color: Color(0xFF616161)),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filtros
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['id'];

                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(filter['name']),
                    avatar: Icon(
                      filter['icon'],
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E88E5),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter['id'];
                      });
                      _filterClinics();
                    },
                    selectedColor: const Color(0xFF1E88E5),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E88E5),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF1E88E5)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Ordenar por
          Row(
            children: [
              const Text(
                'Ordenar por:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF616161),
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

  Widget _buildClinicsList() {
    if (_filteredClinics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: const Color(0xFF616161)),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron veterinarias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF616161),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Intenta con otros filtros o términos de búsqueda',
              style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredClinics.length,
      itemBuilder: (context, index) {
        final clinic = _filteredClinics[index];
        return _buildClinicCard(clinic);
      },
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la clínica con mapa
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E88E5).withOpacity(0.8),
                  const Color(0xFF42A5F5).withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Imagen de mapa de fondo
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      _getMapImage(clinic['id']),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback a gradiente si hay error
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1E88E5).withOpacity(0.8),
                                const Color(0xFF42A5F5).withOpacity(0.8),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Overlay para mejorar legibilidad
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                // Icono de la clínica en el mapa
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Estado abierto/cerrado
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: clinic['is_open']
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      clinic['is_open'] ? 'Abierto' : 'Cerrado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Distancia
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${clinic['distance']} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Información de la clínica
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        clinic['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB74D),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          clinic['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Dirección
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF616161),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        clinic['address'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF616161),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Especialidades
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: clinic['specialties'].map<Widget>((specialty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1E88E5).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Información adicional
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.access_time,
                      '${clinic['wait_time']} min',
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.attach_money,
                      clinic['price_range'],
                      const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.phone,
                      'Llamar',
                      const Color(0xFF9C27B0),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showClinicDetails(clinic);
                        },
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Ver detalles'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E88E5),
                          side: const BorderSide(color: Color(0xFF1E88E5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: clinic['is_open']
                            ? () {
                                _bookAppointment(clinic);
                              }
                            : null,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('Agendar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showClinicDetails(Map<String, dynamic> clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildClinicDetailsModal(clinic),
    );
  }

  Widget _buildClinicDetailsModal(Map<String, dynamic> clinic) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Información detallada
                  _buildDetailRow(
                    Icons.location_on,
                    'Dirección',
                    clinic['address'],
                  ),
                  _buildDetailRow(Icons.phone, 'Teléfono', clinic['phone']),
                  _buildDetailRow(
                    Icons.star,
                    'Calificación',
                    '${clinic['rating']}/5.0',
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    'Tiempo de espera',
                    '${clinic['wait_time']} minutos',
                  ),
                  _buildDetailRow(
                    Icons.attach_money,
                    'Rango de precios',
                    clinic['price_range'],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Especialidades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: clinic['specialties'].map<Widget>((specialty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1E88E5).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Botones de acción
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implementar llamada
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Próximamente: Llamar')),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Llamar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      side: const BorderSide(color: Color(0xFF1E88E5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: clinic['is_open']
                        ? () {
                            Navigator.pop(context);
                            _bookAppointment(clinic);
                          }
                        : null,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Agendar Cita'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E88E5), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF616161)),
            ),
          ),
        ],
      ),
    );
  }

  void _bookAppointment(Map<String, dynamic> clinic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendando cita en ${clinic['name']}...'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
    // TODO: Navegar a pantalla de agendar cita
  }

  String _getMapImage(String clinicId) {
    // Diferentes imágenes de mapa para cada clínica
    final mapImages = {
      '1':
          'https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', // Mapa urbano
      '2':
          'https://images.unsplash.com/photo-1519302959554-a75be0afc82a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', // Mapa de carreteras
      '3':
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', // Vista satelital
      '4':
          'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', // Mapa de ciudad
      '5':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80', // Mapa de calles
    };

    return mapImages[clinicId] ?? mapImages['1']!;
  }
}
