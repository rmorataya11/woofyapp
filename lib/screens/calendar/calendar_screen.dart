import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_utils.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/reminder_model.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future(() => _loadEvents());
  }

  Future<void> _loadEvents() async {
    await ref.read(appointmentProvider.notifier).loadAppointments();
    await ref.read(reminderProvider.notifier).loadReminders();
  }

  List<Appointment> _getEventsForDate(DateTime date) {
    final appointments = ref.read(appointmentProvider).appointments;
    return appointments.where((appointment) {
      return appointment.startsAt.year == date.year &&
          appointment.startsAt.month == date.month &&
          appointment.startsAt.day == date.day;
    }).toList();
  }

  List<Reminder> _getRemindersForDate(DateTime date) {
    final reminders = ref.read(reminderProvider).reminders;
    return reminders.where((reminder) {
      return reminder.dueAt.year == date.year &&
          reminder.dueAt.month == date.month &&
          reminder.dueAt.day == date.day;
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.05),
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
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

  Widget _buildEventCard(Appointment event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getEventColor(event.serviceType).withValues(alpha: 0.3),
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
                  color: _getEventColor(event.serviceType),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${event.serviceType} - ${event.petName ?? "Mascota"}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
              ),
              if (event.isUrgent)
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
                event.appointmentTime,
                style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 16, color: const Color(0xFF616161)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.clinicName ?? 'Clínica',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                ),
              ),
            ],
          ),
          if (event.notes != null && event.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.notes!,
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Editar cita - Próximamente'),
                        backgroundColor: Color(0xFF1E88E5),
                      ),
                    );
                  },
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
                  onPressed: () => _deleteAppointment(event.id),
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

  Widget _buildReminderCard(Reminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getReminderColor(reminder.type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getReminderColor(reminder.type).withValues(alpha: 0.3),
          width: 2,
        ),
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
                  color: _getReminderColor(reminder.type),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                    decoration: reminder.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ],
          ),
          if (reminder.petName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.pets, size: 16, color: const Color(0xFF616161)),
                const SizedBox(width: 8),
                Text(
                  reminder.petName!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ],
          if (reminder.description != null &&
              reminder.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              reminder.description!,
              style: TextStyle(
                fontSize: 14,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: reminder.isCompleted
                      ? null
                      : () => _completeReminder(reminder.id),
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(
                    reminder.isCompleted ? 'Completado' : 'Completar',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteReminder(reminder.id),
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

  Color _getReminderColor(String type) {
    switch (type) {
      case 'vaccine':
        return const Color(0xFF9C27B0);
      case 'deworm':
        return const Color(0xFFFF5722);
      case 'antiflea':
        return const Color(0xFFFF9800);
      case 'checkup':
        return const Color(0xFF00BCD4);
      case 'grooming':
        return const Color(0xFF2196F3);
      case 'other':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF607D8B);
    }
  }

  Future<void> _completeReminder(String reminderId) async {
    final success = await ref
        .read(reminderProvider.notifier)
        .completeReminder(reminderId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recordatorio completado'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al completar recordatorio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteReminder(String reminderId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Recordatorio'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este recordatorio?',
        ),
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
                  .read(reminderProvider.notifier)
                  .deleteReminder(reminderId);

              if (mounted) {
                navigator.pop();

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Recordatorio eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar recordatorio'),
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
    // TODO: Implementar formulario de nueva cita desde calendario
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

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Cita eliminada correctamente'),
                      backgroundColor: Colors.green,
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
}

// TODO: Implementar formulario de eventos/citas desde calendario
