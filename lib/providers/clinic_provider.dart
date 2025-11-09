import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clinic_model.dart';
import '../services/clinic_service.dart';

class ClinicState {
  final List<Clinic> clinics;
  final bool isLoading;
  final String? errorMessage;

  ClinicState({
    required this.clinics,
    this.isLoading = false,
    this.errorMessage,
  });

  ClinicState copyWith({
    List<Clinic>? clinics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ClinicState(
      clinics: clinics ?? this.clinics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory ClinicState.initial() {
    return ClinicState(clinics: []);
  }

  factory ClinicState.loading() {
    return ClinicState(clinics: [], isLoading: true);
  }
}

class ClinicNotifier extends StateNotifier<ClinicState> {
  final ClinicService _clinicService = ClinicService();

  ClinicNotifier() : super(ClinicState.initial()) {
    loadClinics();
  }

  Future<void> loadClinics() async {
    state = ClinicState.loading();

    try {
      final clinics = await _clinicService.getClinics();
      state = ClinicState(clinics: clinics, isLoading: false);
    } catch (e) {
      state = ClinicState(
        clinics: [],
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadNearbyClinics({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final clinics = await _clinicService.getNearbyClinics(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      state = ClinicState(clinics: clinics, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void filterClinics({String? searchQuery, String? filterType}) {}

  Future<void> refresh() async {
    await loadClinics();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final clinicProvider = StateNotifierProvider<ClinicNotifier, ClinicState>((
  ref,
) {
  return ClinicNotifier();
});

final clinicByIdProvider = Provider.family<Clinic?, String>((ref, id) {
  final clinics = ref.watch(clinicProvider).clinics;
  try {
    return clinics.firstWhere((clinic) => clinic.id == id);
  } catch (_) {
    return null;
  }
});
