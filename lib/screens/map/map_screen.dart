import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme_utils.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _clinics = [];
  List<Map<String, dynamic>> _filteredClinics = [];
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
      final response = await _supabase
          .from('clinics')
          .select('*')
          .eq('is_active', true)
          .order('rating', ascending: false);

      if (mounted) {
        setState(() {
          _clinics = response;
          _filteredClinics = _clinics;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _clinics = _getMockClinics();
          _filteredClinics = _clinics;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getMockClinics() {
    return [
      {
        'id': '1',
        'name': 'Clínica Veterinaria Central',
        'address': 'Av. Principal 123, Centro',
        'phone': '+1 234 567 8900',
        'rating': 4.8,
        'distance': 2.5,
        'wait_time': 15,
        'is_open': true,
        'specialties': [
          'Consulta General',
          'Vacunación',
          'Cirugía',
          'Emergencias',
        ],
        'image_url': 'https://via.placeholder.com/300x200',
      },
      {
        'id': '2',
        'name': 'Hospital Veterinario San Rafael',
        'address': 'Calle San Rafael 456, Norte',
        'phone': '+1 234 567 8901',
        'rating': 4.6,
        'distance': 3.2,
        'wait_time': 25,
        'is_open': true,
        'specialties': ['Cardiología', 'Neurología', 'Cirugía'],
        'image_url': 'https://via.placeholder.com/300x200',
      },
      {
        'id': '3',
        'name': 'Centro Veterinario 24/7',
        'address': 'Av. Emergencias 789, Sur',
        'phone': '+1 234 567 8902',
        'rating': 4.9,
        'distance': 1.8,
        'wait_time': 5,
        'is_open': true,
        'specialties': ['Emergencias', 'Cirugía', 'Cardiología'],
        'image_url': 'https://via.placeholder.com/300x200',
      },
      {
        'id': '4',
        'name': 'Clínica PetCare',
        'address': 'Calle PetCare 321, Este',
        'phone': '+1 234 567 8903',
        'rating': 4.4,
        'distance': 4.1,
        'wait_time': 30,
        'is_open': false,
        'specialties': ['Consulta General', 'Vacunación'],
        'image_url': 'https://via.placeholder.com/300x200',
      },
      {
        'id': '5',
        'name': 'Veterinaria Especializada',
        'address': 'Av. Especializada 654, Oeste',
        'phone': '+1 234 567 8904',
        'rating': 4.7,
        'distance': 5.3,
        'wait_time': 20,
        'is_open': true,
        'specialties': ['Cardiología', 'Neurología', 'Oncología'],
        'image_url': 'https://via.placeholder.com/300x200',
      },
    ];
  }

  void _filterClinics() {
    setState(() {
      List<Map<String, dynamic>> filtered = _clinics.where((clinic) {
        bool matchesFilter = true;
        if (_selectedFilter == 'open') {
          matchesFilter = (clinic['is_open'] ?? false) == true;
        } else if (_selectedFilter == 'emergency') {
          final specialties = clinic['specialties'] as List<String>? ?? [];
          matchesFilter = specialties.contains('Emergencias');
        } else if (_selectedFilter == 'surgery') {
          final specialties = clinic['specialties'] as List<String>? ?? [];
          matchesFilter = specialties.contains('Cirugía');
        } else if (_selectedFilter == 'cardiology') {
          final specialties = clinic['specialties'] as List<String>? ?? [];
          matchesFilter = specialties.contains('Cardiología');
        }

        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          final specialties = clinic['specialties'] as List<String>? ?? [];
          matchesSearch =
              clinic['name'].toLowerCase().contains(searchText) ||
              clinic['address'].toLowerCase().contains(searchText) ||
              specialties.any(
                (specialty) => specialty.toLowerCase().contains(searchText),
              );
        }

        return matchesFilter && matchesSearch;
      }).toList();

      filtered.sort((a, b) {
        switch (_selectedSort) {
          case 'distance':
            final distanceA = a['distance'] as double? ?? 0.0;
            final distanceB = b['distance'] as double? ?? 0.0;
            return distanceA.compareTo(distanceB);
          case 'rating':
            final ratingA = a['rating'] as double? ?? 0.0;
            final ratingB = b['rating'] as double? ?? 0.0;
            return ratingB.compareTo(ratingA);
          case 'wait_time':
            final waitA = a['wait_time'] as int? ?? 0;
            final waitB = b['wait_time'] as int? ?? 0;
            return waitA.compareTo(waitB);
          default:
            return 0;
        }
      });

      _filteredClinics = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: ThemeUtils.getBackgroundDecoration(context, ref),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchAndFilters(),
              Expanded(child: _buildMapOnly()),
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
              child: Image.asset(
                'resources/Map.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 80, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Mapa no disponible',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
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
          ..._filteredClinics.map((clinic) => _buildClinicCard(clinic)),
        ],
      ),
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
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
                        clinic['name'],
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
                              clinic['address'],
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (clinic['is_open'] ?? false)
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (clinic['is_open'] ?? false) ? 'Abierto' : 'Cerrado',
                    style: TextStyle(
                      fontSize: 12,
                      color: (clinic['is_open'] ?? false)
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${clinic['rating']} ⭐',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF616161),
                ),
                const SizedBox(width: 4),
                Text(
                  '${clinic['wait_time']} min',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showContactModal(clinic),
                  icon: const Icon(Icons.email, size: 16),
                  label: const Text('Contactar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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

  void _showContactModal(Map<String, dynamic> clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactModal(clinic: clinic),
    );
  }
}

class _ContactModal extends StatefulWidget {
  final Map<String, dynamic> clinic;

  const _ContactModal({required this.clinic});

  @override
  _ContactModalState createState() => _ContactModalState();
}

class _ContactModalState extends State<_ContactModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

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
                        widget.clinic['name'],
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
                          onPressed: _sendMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Enviar'),
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

  void _sendMessage() {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mensaje enviado a ${widget.clinic['name']}'),
        backgroundColor: Colors.green,
      ),
    );

    context.pop();
  }
}
