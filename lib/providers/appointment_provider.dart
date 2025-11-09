import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentState {
  final List<Appointment> appointments;
  final List<AppointmentRequest> requests;
  final bool isLoading;
  final String? errorMessage;

  AppointmentState({
    required this.appointments,
    required this.requests,
    this.isLoading = false,
    this.errorMessage,
  });

  AppointmentState copyWith({
    List<Appointment>? appointments,
    List<AppointmentRequest>? requests,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory AppointmentState.initial() {
    return AppointmentState(appointments: [], requests: []);
  }

  factory AppointmentState.loading() {
    return AppointmentState(appointments: [], requests: [], isLoading: true);
  }
}

class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final AppointmentService _appointmentService = AppointmentService();

  AppointmentNotifier() : super(AppointmentState.initial()) {
    loadAppointments();
    loadRequests();
  }

  Future<void> loadAppointments({String? status}) async {
    state = state.copyWith(isLoading: true);

    try {
      final appointments = await _appointmentService.getAppointments(
        status: status,
      );

      state = AppointmentState(
        appointments: appointments,
        requests: state.requests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadRequests({String? status}) async {
    try {
      final requests = await _appointmentService.getAppointmentRequests(
        status: status,
      );

      state = state.copyWith(requests: requests);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> createAppointment({
    required String clinicId,
    required String petId,
    required String serviceId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final newAppointment = await _appointmentService.createAppointment(
        clinicId: clinicId,
        petId: petId,
        serviceId: serviceId,
        startsAt: startsAt,
        endsAt: endsAt,
        notes: notes,
      );

      state = AppointmentState(
        appointments: [...state.appointments, newAppointment],
        requests: state.requests,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateAppointment({
    required String id,
    DateTime? startsAt,
    DateTime? endsAt,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final updatedAppointment = await _appointmentService.updateAppointment(
        id: id,
        startsAt: startsAt,
        endsAt: endsAt,
        notes: notes,
      );

      state = AppointmentState(
        appointments: state.appointments
            .map((apt) => apt.id == id ? updatedAppointment : apt)
            .toList(),
        requests: state.requests,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateAppointmentStatus({
    required String id,
    required String status,
  }) async {
    try {
      final updatedAppointment = await _appointmentService
          .updateAppointmentStatus(id: id, status: status);

      state = AppointmentState(
        appointments: state.appointments
            .map((apt) => apt.id == id ? updatedAppointment : apt)
            .toList(),
        requests: state.requests,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteAppointment(String id) async {
    try {
      await _appointmentService.deleteAppointment(id);

      state = AppointmentState(
        appointments: state.appointments.where((apt) => apt.id != id).toList(),
        requests: state.requests,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> confirmRequest({
    required String requestId,
    String? finalDate,
    String? finalTime,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _appointmentService.confirmAppointmentRequest(
        requestId: requestId,
        finalDate: finalDate,
        finalTime: finalTime,
        notes: notes,
      );

      final newAppointment = Appointment.fromJson(
        result['appointment'] as Map<String, dynamic>,
      );

      final updatedRequest = AppointmentRequest.fromJson(
        result['request'] as Map<String, dynamic>,
      );

      state = AppointmentState(
        appointments: [...state.appointments, newAppointment],
        requests: state.requests
            .map((req) => req.id == requestId ? updatedRequest : req)
            .toList(),
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> cancelRequest({
    required String requestId,
    String? reason,
  }) async {
    try {
      await _appointmentService.cancelAppointmentRequest(
        requestId: requestId,
        reason: reason,
      );

      await loadRequests();

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    await loadAppointments();
    await loadRequests();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
      return AppointmentNotifier();
    });

final pendingRequestsProvider = Provider<List<AppointmentRequest>>((ref) {
  final state = ref.watch(appointmentProvider);
  return state.requests
      .where((req) => req.status == AppointmentRequest.statusPending)
      .toList();
});

final upcomingAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final state = ref.watch(appointmentProvider);
  final now = DateTime.now();
  return state.appointments
      .where(
        (apt) =>
            apt.startsAt.isAfter(now) &&
            (apt.status == 'scheduled' || apt.status == 'confirmed'),
      )
      .toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
});
