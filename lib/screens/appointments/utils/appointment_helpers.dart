import '../../../models/appointment_model.dart';

class AppointmentHelpers {
  /// Filtrar citas por estado
  static List<Appointment> filterByStatus(
    List<Appointment> appointments,
    String filter,
  ) {
    if (filter == 'all') return appointments;

    return appointments.where((appointment) {
      switch (filter) {
        case 'scheduled':
          return appointment.status == 'scheduled';
        case 'confirmed':
          return appointment.status == 'confirmed';
        case 'completed':
          return appointment.status == 'completed';
        case 'cancelled':
          return appointment.status == 'cancelled';
        case 'urgent':
          return appointment.isUrgent;
        default:
          return true;
      }
    }).toList();
  }

  /// Filtrar citas por búsqueda
  static List<Appointment> filterBySearch(
    List<Appointment> appointments,
    String searchText,
  ) {
    if (searchText.isEmpty) return appointments;

    final lowerSearch = searchText.toLowerCase();
    return appointments.where((appointment) {
      final title = '${appointment.serviceType} - ${appointment.petName}';
      return title.toLowerCase().contains(lowerSearch) ||
          (appointment.petName?.toLowerCase().contains(lowerSearch) ?? false) ||
          (appointment.clinicName?.toLowerCase().contains(lowerSearch) ?? false);
    }).toList();
  }

  /// Ordenar citas
  static List<Appointment> sortAppointments(
    List<Appointment> appointments,
    String sortBy,
  ) {
    final sorted = List<Appointment>.from(appointments);

    sorted.sort((a, b) {
      switch (sortBy) {
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

    return sorted;
  }

  /// Filtrar y ordenar citas (combinado)
  static List<Appointment> filterAndSort(
    List<Appointment> appointments, {
    required String filter,
    required String searchText,
    required String sortBy,
  }) {
    List<Appointment> result = appointments;

    // Aplicar filtro de estado
    result = filterByStatus(result, filter);

    // Aplicar búsqueda
    result = filterBySearch(result, searchText);

    // Aplicar ordenamiento
    result = sortAppointments(result, sortBy);

    return result;
  }

  /// Calcular estadísticas
  static Map<String, int> calculateStats(List<Appointment> appointments) {
    return {
      'total': appointments.length,
      'scheduled': appointments.where((a) => a.status == 'scheduled').length,
      'confirmed': appointments.where((a) => a.status == 'confirmed').length,
      'completed': appointments.where((a) => a.status == 'completed').length,
      'cancelled': appointments.where((a) => a.status == 'cancelled').length,
      'urgent': appointments.where((a) => a.isUrgent).length,
    };
  }

  /// Obtener color por estado
  static int getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return 0xFF2196F3;
      case 'confirmed':
        return 0xFF4CAF50;
      case 'completed':
        return 0xFF9C27B0;
      case 'cancelled':
        return 0xFFF44336;
      default:
        return 0xFF757575;
    }
  }

  /// Obtener icono por estado
  static int getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return 0xe8b5; // Icons.schedule
      case 'confirmed':
        return 0xe86c; // Icons.check_circle
      case 'completed':
        return 0xe876; // Icons.done_all
      case 'cancelled':
        return 0xe5c9; // Icons.cancel
      default:
        return 0xe88e; // Icons.event
    }
  }

  /// Obtener texto legible del estado
  static String getStatusText(String status) {
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
}

