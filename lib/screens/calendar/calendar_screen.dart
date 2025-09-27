import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
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
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Cargar eventos del usuario
        final eventsResponse = await _supabase
            .from('appointments')
            .select('*, pets(name), clinics(name)')
            .eq('user_id', user.id)
            .gte(
              'appointment_date',
              DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String(),
            )
            .lte(
              'appointment_date',
              DateTime.now().add(const Duration(days: 365)).toIso8601String(),
            );

        // Cargar recordatorios
        final remindersResponse = await _supabase
            .from('reminders')
            .select('*, pets(name)')
            .eq('user_id', user.id)
            .eq('is_active', true);

        setState(() {
          _events = List<Map<String, dynamic>>.from(eventsResponse);
          _reminders = List<Map<String, dynamic>>.from(remindersResponse);
        });
      }
    } catch (e) {
      print('Error cargando eventos: $e');
      // Datos mock si hay error
      setState(() {
        _events = _getMockEvents();
        _reminders = _getMockReminders();
      });
    } finally {
      // Eventos cargados
    }
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildMonthSelector(),
              _buildCalendar(),
              Expanded(child: _buildEventsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFF1E88E5), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mi Calendario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ),
          IconButton(
            onPressed: _showToday,
            icon: const Icon(Icons.today, color: Color(0xFF1E88E5), size: 24),
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
            icon: const Icon(
              Icons.chevron_left,
              color: Color(0xFF1E88E5),
              size: 28,
            ),
          ),
          Text(
            _getMonthYearString(_currentMonth),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(
              Icons.chevron_right,
              color: Color(0xFF1E88E5),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF616161),
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
                ? const Color(0xFF1E88E5)
                : isToday
                ? const Color(0xFF1E88E5).withOpacity(0.1)
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
                        ? const Color(0xFF1E88E5)
                        : const Color(0xFF212121),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.event, color: Color(0xFF1E88E5), size: 20),
                const SizedBox(width: 8),
                Text(
                  _getSelectedDateString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const Spacer(),
                Text(
                  '${selectedEvents.length + selectedReminders.length} eventos',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedEvents.isEmpty && selectedReminders.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.all(16),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: const Color(0xFF616161).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay eventos para este día',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF616161),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca el botón + para agregar un evento',
            style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getEventColor(event['type']).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getEventColor(event['type']).withOpacity(0.1),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
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
                    color: const Color(0xFFF44336),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161),
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
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.3),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.notifications, color: const Color(0xFFFF9800), size: 20),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Agregar nuevo evento'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    // TODO: Navegar a pantalla de agregar evento
  }
}
