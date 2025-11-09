import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_utils.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _events = _getMockEvents();
      _reminders = _getMockReminders();
    });
  }

  List<Map<String, dynamic>> _getMockEvents() {
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
        'pet_name': 'Max',
        'notes': 'Vacuna anual contra enfermedades comunes',
        'urgent': false,
      },
      {
        'id': '2',
        'title': 'Control de Peso - Luna',
        'appointment_date': now.add(const Duration(days: 5)).toIso8601String(),
        'time': '2:00 PM',
        'type': 'checkup',
        'status': 'scheduled',
        'clinic_name': 'Hospital San Patricio',
        'pet_name': 'Luna',
        'notes': 'Control de peso y revisión general',
        'urgent': true,
      },
      {
        'id': '3',
        'title': 'Cirugía de Castración - Rocky',
        'appointment_date': now.add(const Duration(days: 10)).toIso8601String(),
        'time': '8:00 AM',
        'type': 'surgery',
        'status': 'scheduled',
        'clinic_name': 'Centro Médico Animal',
        'pet_name': 'Rocky',
        'notes': 'Cirugía de castración programada',
        'urgent': false,
      },
      {
        'id': '4',
        'title': 'Limpieza Dental - Bella',
        'appointment_date': now.add(const Duration(days: 15)).toIso8601String(),
        'time': '11:30 AM',
        'type': 'dental',
        'status': 'scheduled',
        'clinic_name': 'Clínica del Perro Feliz',
        'pet_name': 'Bella',
        'notes': 'Limpieza dental profesional',
        'urgent': false,
      },
    ];
  }

  List<Map<String, dynamic>> _getMockReminders() {
    return [
      {
        'id': '1',
        'title': 'Recordatorio: Medicamento',
        'reminder_date': DateTime.now()
            .add(const Duration(hours: 2))
            .toIso8601String(),
        'type': 'medication',
        'pet_name': 'Max',
        'description': 'Dar medicamento para el corazón',
        'is_recurring': true,
        'frequency': 'daily',
      },
      {
        'id': '2',
        'title': 'Recordatorio: Ejercicio',
        'reminder_date': DateTime.now()
            .add(const Duration(hours: 4))
            .toIso8601String(),
        'type': 'exercise',
        'pet_name': 'Luna',
        'description': 'Caminata de 30 minutos',
        'is_recurring': true,
        'frequency': 'daily',
      },
      {
        'id': '3',
        'title': 'Recordatorio: Baño',
        'reminder_date': DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String(),
        'type': 'grooming',
        'pet_name': 'Rocky',
        'description': 'Baño y cepillado',
        'is_recurring': true,
        'frequency': 'weekly',
      },
    ];
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    return _events.where((event) {
      final eventDate = DateTime.parse(event['appointment_date']);
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    }).toList();
  }

  List<Map<String, dynamic>> _getRemindersForDate(DateTime date) {
    return _reminders.where((reminder) {
      final reminderDate = DateTime.parse(reminder['reminder_date']);
      return reminderDate.year == date.year &&
          reminderDate.month == date.month &&
          reminderDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: ThemeUtils.getBackgroundDecoration(context, ref),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildMonthSelector(),
                _buildCalendar(),
                _buildEventsList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mi Calendario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: _showToday,
            icon: Icon(
              Icons.today,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          Text(
            _getMonthYearString(_currentMonth),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(children: [_buildWeekDays(), _buildCalendarGrid()]),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeUtils.getTextSecondaryColor(context, ref),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          for (int week = 0; week < 6; week++)
            Row(
              children: [
                for (int day = 0; day < 7; day++)
                  _buildDayCell(week, day, firstWeekday, daysInMonth),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int week, int day, int firstWeekday, int daysInMonth) {
    final dayNumber = (week * 7) + day - firstWeekday + 1;
    final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
    final date = isCurrentMonth
        ? DateTime(_currentMonth.year, _currentMonth.month, dayNumber)
        : null;

    final isToday =
        date != null &&
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    final isSelected =
        date != null &&
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    final hasEvents = date != null && _getEventsForDate(date).isNotEmpty;
    final hasReminders = date != null && _getRemindersForDate(date).isNotEmpty;

    return Expanded(
      child: GestureDetector(
        onTap: isCurrentMonth && date != null
            ? () {
                setState(() {
                  _selectedDate = date;
                });
              }
            : null,
        child: Container(
          height: 50,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : isToday
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isToday && !isSelected
                ? Border.all(color: const Color(0xFF1E88E5), width: 2)
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  isCurrentMonth ? dayNumber.toString() : '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? Theme.of(context).colorScheme.primary
                        : ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
              ),
              if (hasEvents || hasReminders)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: hasEvents
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final selectedEvents = _getEventsForDate(_selectedDate);
    final selectedReminders = _getRemindersForDate(_selectedDate);

    return Container(
      margin: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getSelectedDateString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
                const Spacer(),
                Text(
                  '${selectedEvents.length + selectedReminders.length} eventos',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                ),
              ],
            ),
          ),
          if (selectedEvents.isEmpty && selectedReminders.isEmpty)
            _buildEmptyState()
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...selectedEvents.map((event) => _buildEventCard(event)),
                  ...selectedReminders.map(
                    (reminder) => _buildReminderCard(reminder),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay eventos para este día',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar un evento',
              style: TextStyle(
                fontSize: 14,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getEventColor(event['type']).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getEventColor(event['type']),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
              ),
              if (event['urgent'])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Urgente',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: const Color(0xFF616161)),
              const SizedBox(width: 8),
              Text(
                event['time'],
                style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 16, color: const Color(0xFF616161)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event['clinic_name'],
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                ),
              ),
            ],
          ),
          if (event['notes'] != null && event['notes'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event['notes'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editAppointment(event),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteAppointment(event['id']),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.notifications,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'vaccine':
        return const Color(0xFF4CAF50);
      case 'checkup':
        return const Color(0xFF2196F3);
      case 'surgery':
        return const Color(0xFFF44336);
      case 'dental':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF1E88E5);
    }
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getSelectedDateString() {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${_selectedDate.day} de ${months[_selectedDate.month - 1]}';
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _showToday() {
    setState(() {
      _currentMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  void _addNewEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventFormModal(onSave: _saveEvent),
    );
  }

  void _editAppointment(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _EventFormModal(event: appointment, onSave: _saveEvent),
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
                _events.removeWhere((event) => event['id'] == appointmentId);
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

  void _saveEvent(Map<String, dynamic> eventData) {
    setState(() {
      if (eventData['id'] == null) {
        eventData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        _events.add(eventData);
      } else {
        // Editar evento existente
        final index = _events.indexWhere(
          (event) => event['id'] == eventData['id'],
        );
        if (index != -1) {
          _events[index] = eventData;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          eventData['id'] == null ? 'Evento agregado' : 'Evento actualizado',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _EventFormModal extends StatefulWidget {
  final Map<String, dynamic>? event;
  final Function(Map<String, dynamic>) onSave;

  const _EventFormModal({this.event, required this.onSave});

  @override
  State<_EventFormModal> createState() => _EventFormModalState();
}

class _EventFormModalState extends State<_EventFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _eventType = 'appointment';
  String _petName = 'Max';
  bool _urgent = false;
  bool _isAllDay = false;

  final List<String> _mockPets = [
    'Max',
    'Luna',
    'Bella',
    'Rocky',
    'Mia',
    'Charlie',
    'Daisy',
    'Buddy',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!['title'] ?? '';
      _descriptionController.text = widget.event!['description'] ?? '';
      _locationController.text = widget.event!['location'] ?? '';
      _notesController.text = widget.event!['notes'] ?? '';
      _eventType = widget.event!['event_type'] ?? 'appointment';
      _petName = widget.event!['pet_name'] ?? 'Max';
      _urgent = widget.event!['urgent'] ?? false;
      _isAllDay = widget.event!['is_all_day'] ?? false;
      _selectedDate = DateTime.parse(widget.event!['appointment_date']);
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.event == null ? 'Nuevo Evento' : 'Editar Evento',
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
                    DropdownButtonFormField<String>(
                      initialValue: _eventType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de evento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'appointment',
                          child: Text('Cita Veterinaria'),
                        ),
                        DropdownMenuItem(
                          value: 'reminder',
                          child: Text('Recordatorio'),
                        ),
                        DropdownMenuItem(value: 'event', child: Text('Evento')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _eventType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título del evento',
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
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _petName,
                      decoration: const InputDecoration(
                        labelText: 'Mascota',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      items: _mockPets.map((pet) {
                        return DropdownMenuItem(value: pet, child: Text(pet));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _petName = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_eventType == 'appointment') ...[
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Clínica/Ubicación',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (_eventType == 'appointment' &&
                              (value == null || value.isEmpty)) {
                            return 'Por favor ingresa la ubicación';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
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
                        if (!_isAllDay) ...[
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Todo el día'),
                      subtitle: const Text('Evento que dura todo el día'),
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Urgente'),
                      subtitle: const Text('Marcar como evento urgente'),
                      value: _urgent,
                      onChanged: (value) {
                        setState(() {
                          _urgent = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas adicionales (opcional)',
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
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveEvent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              widget.event == null ? 'Agregar' : 'Actualizar',
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

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final eventData = {
        'id': widget.event?['id'],
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'notes': _notesController.text,
        'event_type': _eventType,
        'pet_name': _petName,
        'urgent': _urgent,
        'is_all_day': _isAllDay,
        'appointment_date': DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _isAllDay ? 0 : _selectedTime.hour,
          _isAllDay ? 0 : _selectedTime.minute,
        ).toIso8601String(),
        'time': _isAllDay ? 'Todo el día' : _selectedTime.format(context),
        'status': 'scheduled',
        'clinic_name': _locationController.text,
        'type': _eventType == 'appointment' ? 'vaccine' : _eventType,
      };

      widget.onSave(eventData);
      Navigator.of(context).pop();
    }
  }
}
