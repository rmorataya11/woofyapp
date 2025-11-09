import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_utils.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  List<Appointment> _filteredAppointments = [];

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
    await ref.read(appointmentProvider.notifier).loadAppointments();
    _filterAppointments();
    _animationController.forward();
  }

  void _filterAppointments() {
    final allAppointments = ref.read(appointmentProvider).appointments;

    setState(() {
      _filteredAppointments = allAppointments.where((appointment) {
        bool matchesFilter = true;
        if (_selectedFilter == 'scheduled') {
          matchesFilter = appointment.status == 'scheduled';
        } else if (_selectedFilter == 'confirmed') {
          matchesFilter = appointment.status == 'confirmed';
        } else if (_selectedFilter == 'completed') {
          matchesFilter = appointment.status == 'completed';
        } else if (_selectedFilter == 'cancelled') {
          matchesFilter = appointment.status == 'cancelled';
        } else if (_selectedFilter == 'urgent') {
          matchesFilter = appointment.isUrgent;
        }

        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          final title = '${appointment.serviceType} - ${appointment.petName}';
          matchesSearch =
              title.toLowerCase().contains(searchText) ||
              (appointment.petName?.toLowerCase().contains(searchText) ??
                  false) ||
              (appointment.clinicName?.toLowerCase().contains(searchText) ??
                  false);
        }

        return matchesFilter && matchesSearch;
      }).toList();

      _filteredAppointments.sort((a, b) {
        switch (_selectedSort) {
          case 'date':
            return a.startsAt.compareTo(b.startsAt);
          case 'status':
            return a.status.compareTo(b.status);
          case 'urgent':
            return (b.isUrgent ? 1 : 0).compareTo(a.isUrgent ? 1 : 0);
          default:
            return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentProvider);

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
                child: appointmentState.isLoading
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
              ).withValues(alpha: 0.5),
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

  Widget _buildAppointmentCard(Appointment appointment) {
    final appointmentDate = appointment.startsAt;
    final isToday = appointment.isToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          controlAffinity: ListTileControlAffinity.trailing,
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _getAppointmentColor(appointment.status),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          title: Text(
            '${appointment.serviceType} - ${appointment.petName ?? "Mascota"}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: ThemeUtils.getTextPrimaryColor(context, ref),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 13,
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDate(appointmentDate)} - ${appointment.appointmentTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : ThemeUtils.getTextSecondaryColor(context, ref),
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 13,
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        appointment.petName ?? 'Mascota',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeUtils.getTextSecondaryColor(context, ref),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (appointment.isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Urgente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (appointment.isUrgent) const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _getAppointmentColor(appointment.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(appointment.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: Alignment.centerLeft,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        appointment.clinicName ?? 'Clínica',
                        style: TextStyle(
                          fontSize: 13,
                          color: ThemeUtils.getTextSecondaryColor(context, ref),
                        ),
                      ),
                    ),
                  ],
                ),
                if (appointment.notes != null &&
                    appointment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ThemeUtils.getTextSecondaryColor(
                        context,
                        ref,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note,
                          size: 14,
                          color: ThemeUtils.getTextSecondaryColor(context, ref),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            appointment.notes!,
                            style: TextStyle(
                              fontSize: 12,
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
                const SizedBox(height: 12),
                _buildActionButtons(appointment),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Appointment appointment) {
    final status = appointment.status;
    final appointmentDate = appointment.startsAt;

    return Column(
      children: [
        Row(
          children: [
            if (status == 'scheduled' &&
                !appointmentDate.isBefore(DateTime.now())) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text(
                    'Confirmar',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rescheduleAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.schedule, size: 14),
                  label: const Text(
                    'Reagendar',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF44336),
                    side: const BorderSide(color: Color(0xFFF44336)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.cancel, size: 14),
                  label: const Text('Cancelar', style: TextStyle(fontSize: 11)),
                ),
              ),
            ] else if (status == 'confirmed' &&
                !appointmentDate.isBefore(DateTime.now())) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rescheduleAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.schedule, size: 14),
                  label: const Text(
                    'Reagendar',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF44336),
                    side: const BorderSide(color: Color(0xFFF44336)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.cancel, size: 14),
                  label: const Text('Cancelar', style: TextStyle(fontSize: 11)),
                ),
              ),
            ] else if (status == 'completed')
              ...[
            ] else if (status == 'cancelled') ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rescheduleAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.schedule, size: 14),
                  label: const Text(
                    'Reagendar',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showMoreActions(appointment),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.more_horiz, size: 14),
            label: const Text('Más opciones', style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    final allAppointments = ref.read(appointmentProvider).appointments;

    int total = allAppointments.length;
    int upcoming = allAppointments
        .where((apt) => apt.status == 'scheduled' || apt.status == 'confirmed')
        .length;
    int completed = allAppointments
        .where((apt) => apt.status == 'completed')
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

  Future<void> _confirmAppointment(Appointment appointment) async {
    final success = await ref
        .read(appointmentProvider.notifier)
        .updateAppointmentStatus(id: appointment.id, status: 'confirmed');

    if (mounted) {
      _filterAppointments();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cita confirmada: ${appointment.serviceType} - ${appointment.petName}',
            ),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al confirmar cita'),
            backgroundColor: Color(0xFFF44336),
          ),
        );
      }
    }
  }

  void _rescheduleAppointment(Appointment appointment) {
    // TODO: Implementar pantalla de reagendamiento en futuras mejoras
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reagendar cita - Próximamente'),
        backgroundColor: Color(0xFF1E88E5),
      ),
    );
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final success = await ref
                  .read(appointmentProvider.notifier)
                  .updateAppointmentStatus(
                    id: appointment.id,
                    status: 'cancelled',
                  );

              if (mounted) {
                navigator.pop();
                _filterAppointments();

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cita cancelada: ${appointment.serviceType} - ${appointment.petName}',
                      ),
                      backgroundColor: const Color(0xFFF44336),
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Error al cancelar cita'),
                      backgroundColor: Color(0xFFF44336),
                    ),
                  );
                }
              }
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

  void _showMoreActions(Appointment appointment) {
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Acciones para: ${appointment.serviceType} - ${appointment.petName}',
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
                      // TODO: Editar cita - Implementar en futuras mejoras
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Editar cita - Próximamente'),
                          backgroundColor: Color(0xFF1E88E5),
                        ),
                      );
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
                      _deleteAppointment(appointment.id);
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
    // TODO: Implementar formulario de nueva cita
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nueva cita - Próximamente'),
        backgroundColor: Color(0xFF1E88E5),
      ),
    );
  }

  Future<void> _deleteAppointment(String appointmentId) async {
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final success = await ref
                  .read(appointmentProvider.notifier)
                  .deleteAppointment(appointmentId);

              if (mounted) {
                navigator.pop();
                _filterAppointments();

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Cita eliminada'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar cita'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
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

// TODO: Implementar formulario de nueva cita/edición con el backend
// Usará createAppointment/updateAppointment del appointmentProvider
// Seleccionará mascota y clínica de los providers correspondientes
