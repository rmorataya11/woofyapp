import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class ReminderState {
  final List<Reminder> reminders;
  final bool isLoading;
  final String? errorMessage;

  ReminderState({
    required this.reminders,
    this.isLoading = false,
    this.errorMessage,
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory ReminderState.initial() {
    return ReminderState(reminders: []);
  }

  factory ReminderState.loading() {
    return ReminderState(reminders: [], isLoading: true);
  }
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ReminderService _reminderService = ReminderService();

  ReminderNotifier() : super(ReminderState.initial()) {
    loadReminders();
  }

  Future<void> loadReminders({String? petId, bool? isCompleted}) async {
    state = state.copyWith(isLoading: true);

    try {
      final reminders = await _reminderService.getReminders(
        petId: petId,
        isCompleted: isCompleted,
      );

      state = ReminderState(reminders: reminders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createReminder({
    String? petId,
    required String title,
    String? description,
    required DateTime reminderDate,
    required String reminderTime,
    required String type,
    bool isRecurring = false,
    String? frequency,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final newReminder = await _reminderService.createReminder(
        petId: petId,
        title: title,
        description: description,
        reminderDate: reminderDate,
        reminderTime: reminderTime,
        type: type,
        isRecurring: isRecurring,
        frequency: frequency,
      );

      state = ReminderState(
        reminders: [...state.reminders, newReminder],
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateReminder({
    required String id,
    String? petId,
    String? title,
    String? description,
    DateTime? reminderDate,
    String? reminderTime,
    String? type,
    bool? isRecurring,
    String? frequency,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final updatedReminder = await _reminderService.updateReminder(
        id: id,
        petId: petId,
        title: title,
        description: description,
        reminderDate: reminderDate,
        reminderTime: reminderTime,
        type: type,
        isRecurring: isRecurring,
        frequency: frequency,
      );

      state = ReminderState(
        reminders: state.reminders
            .map((rem) => rem.id == id ? updatedReminder : rem)
            .toList(),
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> completeReminder(String id) async {
    try {
      final updatedReminder = await _reminderService.completeReminder(id);

      state = ReminderState(
        reminders: state.reminders
            .map((rem) => rem.id == id ? updatedReminder : rem)
            .toList(),
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      await _reminderService.deleteReminder(id);

      state = ReminderState(
        reminders: state.reminders.where((rem) => rem.id != id).toList(),
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    await loadReminders();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, ReminderState>(
  (ref) {
    return ReminderNotifier();
  },
);

final todayRemindersProvider = Provider<List<Reminder>>((ref) {
  final state = ref.watch(reminderProvider);
  final now = DateTime.now();
  return state.reminders
      .where(
        (reminder) =>
            reminder.reminderDate.year == now.year &&
            reminder.reminderDate.month == now.month &&
            reminder.reminderDate.day == now.day &&
            !reminder.isCompleted,
      )
      .toList()
    ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
});

final pendingRemindersProvider = Provider<List<Reminder>>((ref) {
  final state = ref.watch(reminderProvider);
  return state.reminders.where((reminder) => !reminder.isCompleted).toList()
    ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
});

final urgentRemindersProvider = Provider<List<Reminder>>((ref) {
  final state = ref.watch(reminderProvider);
  final now = DateTime.now();
  return state.reminders
      .where(
        (reminder) =>
            reminder.reminderDate.year == now.year &&
            reminder.reminderDate.month == now.month &&
            reminder.reminderDate.day == now.day &&
            !reminder.isCompleted,
      )
      .toList()
    ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
});
