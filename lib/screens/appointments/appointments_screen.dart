import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_utils.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  bool _isLoading = true;

  String _selectedFilter = 'all';
  String _selectedSort = 'date';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _filters = [
    {
      'id': 'all',
      'name': 'Todas',
      'icon': Icons.list,
      'color': Color(0xFF1E88E5),
    },
    {
      'id': 'scheduled',
      'name': 'Programadas',
      'icon': Icons.schedule,
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'confirmed',
      'name': 'Confirmadas',
      'icon': Icons.check_circle,
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'completed',
      'name': 'Completadas',
      'icon': Icons.done_all,
      'color': Color(0xFF9C27B0),
    },
    {
      'id': 'cancelled',
      'name': 'Canceladas',
      'icon': Icons.cancel,
      'color': Color(0xFFF44336),
    },
    {
      'id': 'urgent',
      'name': 'Urgentes',
      'icon': Icons.priority_high,
      'color': Color(0xFFFF9800),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _loadAppointments();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _appointments = _getMockAppointments();
      _filteredAppointments = List.from(_appointments);
      _isLoading = false;
    });
    _animationController.forward();
  }

  List<Map<String, dynamic>> _getMockAppointments() {
    final now = DateTime.now();
    return [
      {
        'id': '1',
        'title': 'Vacuna Triple - Max',
        'appointment_date': now.add(const Duration(days: 2)).toIso8601String(),
        'time': '10:00 AM',
        'type': 'vaccine',
        'status': 'scheduled',
        'clinic_name': 'Clínica Veterinaria Central',
        'clinic_address': 'Av. Principal 123, Ciudad',
        'clinic_phone': '+1-555-0123',
        'pet_name': 'Max',
        'pet_breed': 'Golden Retriever',
        'pet_age': 3,
        'notes': 'Vacuna anual contra enfermedades comunes',
        'urgent': false,
        'estimated_duration': 30,
        'cost': 150.00,
        'doctor_name': 'Dr. María González',
        'specialty': 'Medicina General',
      },
      {
        'id': '2',
        'title': 'Control de Peso - Luna',
        'appointment_date': now.add(const Duration(days: 5)).toIso8601String(),
        'time': '2:00 PM',
        'type': 'checkup',
        'status': 'confirmed',
        'clinic_name': 'Hospital San Patricio',
        'clinic_address': 'Calle Secundaria 456, Ciudad',
        'clinic_phone': '+1-555-0456',
        'pet_name': 'Luna',
        'pet_breed': 'Labrador',
        'pet_age': 2,
        'notes': 'Control de peso y revisión general',
        'urgent': true,
        'estimated_duration': 45,
        'cost': 200.00,
        'doctor_name': 'Dr. Carlos Rodríguez',
        'specialty': 'Nutrición',
      },
      {
        'id': '3',
        'title': 'Cirugía de Castración - Rocky',
        'appointment_date': now.add(const Duration(days: 10)).toIso8601String(),
        'time': '8:00 AM',
        'type': 'surgery',
        'status': 'scheduled',
        'clinic_name': 'Centro Médico Animal',
        'clinic_address': 'Boulevard Norte 789, Ciudad',
        'clinic_phone': '+1-555-0789',
        'pet_name': 'Rocky',
        'pet_breed': 'Pastor Alemán',
        'pet_age': 1,
        'notes': 'Cirugía de castración programada',
        'urgent': false,
        'estimated_duration': 120,
        'cost': 500.00,
        'doctor_name': 'Dr. Ana Martínez',
        'specialty': 'Cirugía',
      },
      {
        'id': '4',
        'title': 'Limpieza Dental - Bella',
        'appointment_date': now.add(const Duration(days: 15)).toIso8601String(),
        'time': '11:30 AM',
        'type': 'dental',
        'status': 'completed',
        'clinic_name': 'Clínica del Perro Feliz',
        'clinic_address': 'Calle de las Flores 654, Ciudad',
        'clinic_phone': '+1-555-0654',
        'pet_name': 'Bella',
        'pet_breed': 'Poodle',
        'pet_age': 4,
        'notes': 'Limpieza dental profesional completada',
        'urgent': false,
        'estimated_duration': 60,
        'cost': 180.00,
        'doctor_name': 'Dr. Luis Fernández',
        'specialty': 'Odontología',
      },
      {
        'id': '5',
        'title': 'Consulta de Emergencia - Rex',
        'appointment_date': now
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'time': '6:00 PM',
        'type': 'emergency',
        'status': 'cancelled',
        'clinic_name': 'Veterinaria 24/7',
        'clinic_address': 'Plaza Comercial 321, Ciudad',
        'clinic_phone': '+1-555-0321',
        'pet_name': 'Rex',
        'pet_breed': 'Rottweiler',
        'pet_age': 5,
        'notes': 'Consulta de emergencia cancelada por el cliente',
        'urgent': true,
        'estimated_duration': 90,
        'cost': 300.00,
        'doctor_name': 'Dr. Patricia López',
        'specialty': 'Emergencias',
      },
    ];
  }

  void _filterAppointments() {
    setState(() {
      _filteredAppointments = _appointments.where((appointment) {
        bool matchesFilter = true;
        if (_selectedFilter == 'scheduled') {
          matchesFilter = appointment['status'] == 'scheduled';
        } else if (_selectedFilter == 'confirmed') {
          matchesFilter = appointment['status'] == 'confirmed';
        } else if (_selectedFilter == 'completed') {
          matchesFilter = appointment['status'] == 'completed';
        } else if (_selectedFilter == 'cancelled') {
          matchesFilter = appointment['status'] == 'cancelled';
        } else if (_selectedFilter == 'urgent') {
          matchesFilter = appointment['urgent'] == true;
        }

        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          matchesSearch =
              appointment['title'].toLowerCase().contains(searchText) ||
              appointment['pet_name'].toLowerCase().contains(searchText) ||
              appointment['clinic_name'].toLowerCase().contains(searchText) ||
              appointment['doctor_name'].toLowerCase().contains(searchText);
        }

        return matchesFilter && matchesSearch;
      }).toList();

      _filteredAppointments.sort((a, b) {
        switch (_selectedSort) {
          case 'date':
            return DateTime.parse(
              a['appointment_date'],
            ).compareTo(DateTime.parse(b['appointment_date']));
          case 'status':
            return a['status'].compareTo(b['status']);
          case 'urgent':
            return b['urgent'].toString().compareTo(a['urgent'].toString());
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
        decoration: ThemeUtils.getBackgroundDecoration(context, ref),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsCards(),
              _buildSearchAndFilters(),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildAppointmentsList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewAppointment,
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Cita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
            Icons.event_note,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mis Citas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
            ),
          ),
          IconButton(
            onPressed: _showCalendarView,
            icon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = _calculateStats();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              stats['total'].toString(),
              Icons.event,
              const Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Próximas',
              stats['upcoming'].toString(),
              Icons.schedule,
              const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completadas',
              stats['completed'].toString(),
              Icons.check_circle,
              const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: ThemeUtils.getTextSecondaryColor(context, ref),
            ),
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
          Container(
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
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterAppointments(),
              decoration: InputDecoration(
                hintText: 'Buscar citas...',
                hintStyle: TextStyle(
                  color: ThemeUtils.getTextSecondaryColor(context, ref),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterAppointments();
                        },
                        icon: Icon(
                          Icons.clear,
                          color: ThemeUtils.getTextSecondaryColor(context, ref),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: ThemeUtils.getCardColor(context, ref),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                      color: isSelected ? Colors.white : filter['color'],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter['id'];
                      });
                      _filterAppointments();
                    },
                    selectedColor: filter['color'],
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : filter['color'],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? filter['color']
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Ordenar por:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeUtils.getTextSecondaryColor(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedSort,
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                  _filterAppointments();
                },
                items: const [
                  DropdownMenuItem(value: 'date', child: Text('Fecha')),
                  DropdownMenuItem(value: 'status', child: Text('Estado')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgencia')),
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

  Widget _buildAppointmentsList() {
    if (_filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: ThemeUtils.getTextSecondaryColor(
                context,
                ref,
              ).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay citas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agendar una nueva cita',
              style: TextStyle(
                fontSize: 14,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _filteredAppointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final appointmentDate = DateTime.parse(appointment['appointment_date']);
    final isToday =
        appointmentDate.day == DateTime.now().day &&
        appointmentDate.month == DateTime.now().month &&
        appointmentDate.year == DateTime.now().year;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAppointmentColor(
                appointment['status'],
              ).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getAppointmentColor(appointment['status']),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeUtils.getTextPrimaryColor(context, ref),
                    ),
                  ),
                ),
                if (appointment['urgent'])
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Urgente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getAppointmentColor(appointment['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(appointment['status']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(appointmentDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : ThemeUtils.getTextSecondaryColor(context, ref),
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      appointment['time'],
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment['clinic_name'],
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeUtils.getTextSecondaryColor(context, ref),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 16,
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${appointment['pet_name']} (${appointment['pet_breed']}, ${appointment['pet_age']} años)',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${appointment['doctor_name']} - ${appointment['specialty']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.timer,
                      '${appointment['estimated_duration']} min',
                      const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.attach_money,
                      '\$${appointment['cost'].toStringAsFixed(0)}',
                      const Color(0xFF4CAF50),
                    ),
                  ],
                ),
                if (appointment['notes'] != null &&
                    appointment['notes'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeUtils.getTextSecondaryColor(
                        context,
                        ref,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: ThemeUtils.getTextSecondaryColor(context, ref),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appointment['notes'],
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
                  ),
                ],
                const SizedBox(height: 16),
                _buildActionButtons(appointment),
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

  Widget _buildActionButtons(Map<String, dynamic> appointment) {
    final status = appointment['status'];
    final appointmentDate = DateTime.parse(appointment['appointment_date']);

    return Column(
      children: [
        Row(
          children: [
            if (status == 'scheduled' &&
                !appointmentDate.isBefore(DateTime.now())) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmAppointment(appointment),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Confirmar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rescheduleAppointment(appointment),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text('Reagendar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelAppointment(appointment),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF44336),
                    side: const BorderSide(color: Color(0xFFF44336)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (status == 'confirmed' &&
                !appointmentDate.isBefore(DateTime.now())) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rescheduleAppointment(appointment),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text('Reagendar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelAppointment(appointment),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF44336),
                    side: const BorderSide(color: Color(0xFFF44336)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (status == 'completed') ...[
            ] else if (status == 'cancelled') ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rescheduleAppointment(appointment),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text('Reagendar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showMoreActions(appointment),
            icon: const Icon(Icons.more_horiz, size: 16),
            label: const Text('Más opciones'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    int total = _appointments.length;
    int upcoming = _appointments
        .where(
          (apt) => apt['status'] == 'scheduled' || apt['status'] == 'confirmed',
        )
        .length;
    int completed = _appointments
        .where((apt) => apt['status'] == 'completed')
        .length;

    return {'total': total, 'upcoming': upcoming, 'completed': completed};
  }

  Color _getAppointmentColor(String status) {
    switch (status) {
      case 'scheduled':
        return const Color(0xFF2196F3);
      case 'confirmed':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF9C27B0);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF1E88E5);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programada';
      case 'confirmed':
        return 'Confirmada';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(date.year, date.month, date.day);

    if (appointmentDay == today) {
      return 'Hoy';
    } else if (appointmentDay == today.add(const Duration(days: 1))) {
      return 'Mañana';
    } else if (appointmentDay == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _confirmAppointment(Map<String, dynamic> appointment) {
    setState(() {
      final index = _appointments.indexWhere(
        (apt) => apt['id'] == appointment['id'],
      );
      if (index != -1) {
        _appointments[index]['status'] = 'confirmed';
      }
    });
    _filterAppointments();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cita confirmada: ${appointment['title']}'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _rescheduleAppointment(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentFormModal(
        appointment: appointment,
        onSave: _saveAppointment,
      ),
    );
  }

  void _cancelAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: const Text('¿Estás seguro de que quieres cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final index = _appointments.indexWhere(
                  (apt) => apt['id'] == appointment['id'],
                );
                if (index != -1) {
                  _appointments[index]['status'] = 'cancelled';
                }
              });
              _filterAppointments();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cita cancelada: ${appointment['title']}'),
                  backgroundColor: const Color(0xFFF44336),
                ),
              );
            },
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreActions(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Acciones para: ${appointment['title']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _editAppointment(appointment);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteAppointment(appointment['id']);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _addNewAppointment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentFormModal(onSave: _saveAppointment),
    );
  }

  void _editAppointment(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentFormModal(
        appointment: appointment,
        onSave: _saveAppointment,
      ),
    );
  }

  void _deleteAppointment(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cita'),
        content: const Text('¿Estás seguro de que quieres eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _appointments.removeWhere(
                  (appointment) => appointment['id'] == appointmentId,
                );
                _filteredAppointments.removeWhere(
                  (appointment) => appointment['id'] == appointmentId,
                );
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita eliminada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveAppointment(Map<String, dynamic> appointmentData) {
    setState(() {
      if (appointmentData['id'] == null) {
        // Nueva cita
        appointmentData['id'] = DateTime.now().millisecondsSinceEpoch
            .toString();
        _appointments.add(appointmentData);
      } else {
        // Editar cita existente
        final index = _appointments.indexWhere(
          (appointment) => appointment['id'] == appointmentData['id'],
        );
        if (index != -1) {
          _appointments[index] = appointmentData;
        }
      }
      _filterAppointments();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appointmentData['id'] == null ? 'Cita agregada' : 'Cita actualizada',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCalendarView() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Vista de calendario'),
        backgroundColor: Color(0xFF1E88E5),
      ),
    );
  }
}

class _AppointmentFormModal extends StatefulWidget {
  final Map<String, dynamic>? appointment;
  final Function(Map<String, dynamic>) onSave;

  const _AppointmentFormModal({this.appointment, required this.onSave});

  @override
  State<_AppointmentFormModal> createState() => _AppointmentFormModalState();
}

class _AppointmentFormModalState extends State<_AppointmentFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _clinicController = TextEditingController();
  final _doctorController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _type = 'vaccine';
  String _status = 'scheduled';
  String _petName = 'Max';
  String _petBreed = 'Golden Retriever';
  int _petAge = 3;
  int _estimatedDuration = 30;
  double _cost = 50.0;
  bool _urgent = false;

  final List<Map<String, dynamic>> _mockPets = [
    {'name': 'Max', 'breed': 'Golden Retriever', 'age': 3},
    {'name': 'Luna', 'breed': 'Labrador', 'age': 2},
    {'name': 'Bella', 'breed': 'Pastor Alemán', 'age': 4},
    {'name': 'Rocky', 'breed': 'Bulldog', 'age': 5},
    {'name': 'Mia', 'breed': 'Chihuahua', 'age': 1},
    {'name': 'Charlie', 'breed': 'Beagle', 'age': 6},
    {'name': 'Daisy', 'breed': 'Poodle', 'age': 2},
    {'name': 'Buddy', 'breed': 'Husky', 'age': 3},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _titleController.text = widget.appointment!['title'] ?? '';
      _clinicController.text = widget.appointment!['clinic_name'] ?? '';
      _doctorController.text = widget.appointment!['doctor_name'] ?? '';
      _specialtyController.text = widget.appointment!['specialty'] ?? '';
      _notesController.text = widget.appointment!['notes'] ?? '';
      _type = widget.appointment!['type'] ?? 'vaccine';
      _status = widget.appointment!['status'] ?? 'scheduled';
      final appointmentPetName = widget.appointment!['pet_name'] ?? 'Max';
      if (_mockPets.any((pet) => pet['name'] == appointmentPetName)) {
        _petName = appointmentPetName;
        final selectedPet = _mockPets.firstWhere(
          (pet) => pet['name'] == appointmentPetName,
        );
        _petBreed = selectedPet['breed'];
        _petAge = selectedPet['age'];
      } else {
        _petName = 'Max';
        _petBreed = 'Golden Retriever';
        _petAge = 3;
      }
      _estimatedDuration = widget.appointment!['estimated_duration'] ?? 30;
      _cost = widget.appointment!['cost']?.toDouble() ?? 50.0;
      _urgent = widget.appointment!['urgent'] ?? false;
      try {
        _selectedDate = DateTime.parse(widget.appointment!['appointment_date']);
        _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
      } catch (e) {
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clinicController.dispose();
    _doctorController.dispose();
    _specialtyController.dispose();
    _notesController.dispose();
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.appointment == null ? 'Nueva Cita' : 'Editar Cita',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título de la cita',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clinicController,
                      decoration: const InputDecoration(
                        labelText: 'Clínica',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el nombre de la clínica';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _doctorController,
                            decoration: const InputDecoration(
                              labelText: 'Doctor',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _specialtyController,
                            decoration: const InputDecoration(
                              labelText: 'Especialidad',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _petName,
                      decoration: const InputDecoration(
                        labelText: 'Mascota',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      items: _mockPets.map<DropdownMenuItem<String>>((pet) {
                        return DropdownMenuItem<String>(
                          value: pet['name'] as String,
                          child: Text(
                            '${pet['name']} (${pet['breed']}, ${pet['age']} años)',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _petName = value!;
                          final selectedPet = _mockPets.firstWhere(
                            (pet) => pet['name'] == value,
                          );
                          _petBreed = selectedPet['breed'];
                          _petAge = selectedPet['age'];
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Hora',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(_selectedTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _type,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de cita',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'vaccine',
                                child: Text('Vacuna'),
                              ),
                              DropdownMenuItem(
                                value: 'checkup',
                                child: Text('Revisión'),
                              ),
                              DropdownMenuItem(
                                value: 'surgery',
                                child: Text('Cirugía'),
                              ),
                              DropdownMenuItem(
                                value: 'emergency',
                                child: Text('Emergencia'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _type = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _status,
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.info),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'scheduled',
                                child: Text('Programada'),
                              ),
                              DropdownMenuItem(
                                value: 'confirmed',
                                child: Text('Confirmada'),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('Completada'),
                              ),
                              DropdownMenuItem(
                                value: 'cancelled',
                                child: Text('Cancelada'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _status = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Urgente'),
                      subtitle: const Text('Marcar como cita urgente'),
                      value: _urgent,
                      onChanged: (value) {
                        setState(() {
                          _urgent = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _estimatedDuration.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Duración (min)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _estimatedDuration = int.tryParse(value) ?? 30;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _cost.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Costo (\$)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _cost = double.tryParse(value) ?? 50.0;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveAppointment,
                            child: Text(
                              widget.appointment == null
                                  ? 'Agregar'
                                  : 'Actualizar',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      final appointmentData = {
        'id': widget.appointment?['id'],
        'title': _titleController.text,
        'clinic_name': _clinicController.text,
        'doctor_name': _doctorController.text,
        'specialty': _specialtyController.text,
        'pet_name': _petName,
        'pet_breed': _petBreed,
        'pet_age': _petAge,
        'notes': _notesController.text,
        'type': _type,
        'status': _status,
        'urgent': _urgent,
        'estimated_duration': _estimatedDuration,
        'cost': _cost,
        'appointment_date': DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ).toIso8601String(),
        'time': _selectedTime.format(context),
      };

      widget.onSave(appointmentData);
      Navigator.of(context).pop();
    }
  }
}
