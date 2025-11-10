import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/clinic_model.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/clinic_provider.dart';
import '../../../services/clinic_service.dart';

class NewEventDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onEventCreated;

  const NewEventDialog({
    super.key,
    required this.selectedDate,
    required this.onEventCreated,
  });

  @override
  ConsumerState<NewEventDialog> createState() => _NewEventDialogState();
}

class _NewEventDialogState extends ConsumerState<NewEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _clinicService = ClinicService();

  String _eventType = 'reminder';
  String? _selectedPetId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedClinicId;
  String? _selectedServiceId;
  List<ClinicServiceModel> _services = [];
  bool _loadingServices = false;
  TimeOfDay? _endTime;

  String _reminderType = 'vaccine';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    Future(() {
      ref.read(petNotifierProvider.notifier).loadPets();
      ref.read(clinicProvider.notifier).loadClinics();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadServices(String clinicId) async {
    setState(() {
      _loadingServices = true;
      _services = [];
      _selectedServiceId = null;
    });

    try {
      final services = await _clinicService.getClinicServices(clinicId);
      setState(() {
        _services = services.where((s) => s.isActive).toList();
        _loadingServices = false;
      });
    } catch (e) {
      setState(() => _loadingServices = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar servicios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        if (_eventType == 'appointment' && _endTime == null) {
          final startMinutes = picked.hour * 60 + picked.minute;
          final endMinutes = startMinutes + 60;
          _endTime = TimeOfDay(
            hour: (endMinutes ~/ 60) % 24,
            minute: endMinutes % 60,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validaciones comunes
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una mascota'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona fecha y hora'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    bool success = false;

    if (_eventType == 'appointment') {
      if (_selectedClinicId == null ||
          _selectedServiceId == null ||
          _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completa todos los campos de la cita'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final startsAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final endsAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      success = await ref
          .read(appointmentProvider.notifier)
          .createAppointment(
            clinicId: _selectedClinicId!,
            petId: _selectedPetId!,
            serviceId: _selectedServiceId!,
            startsAt: startsAt,
            endsAt: endsAt,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );
    } else {
      // Crear recordatorio
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El título es requerido'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final dueAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      success = await ref
          .read(reminderProvider.notifier)
          .createReminder(
            petId: _selectedPetId!,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            dueAt: dueAt,
            type: _reminderType,
          );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        Navigator.of(context).pop();
        widget.onEventCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _eventType == 'appointment'
                  ? 'Cita creada exitosamente'
                  : 'Recordatorio creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _eventType == 'appointment'
                  ? 'Error al crear la cita'
                  : 'Error al crear el recordatorio',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petNotifierProvider);
    final clinics = ref.watch(clinicProvider).clinics;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _eventType == 'appointment'
                        ? Icons.event
                        : Icons.notifications_active,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _eventType == 'appointment'
                          ? 'Nueva Cita'
                          : 'Nuevo Recordatorio',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Formulario
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Evento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() {
                                _eventType = 'reminder';
                                _selectedClinicId = null;
                                _selectedServiceId = null;
                                _services = [];
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _eventType == 'reminder'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: _eventType == 'reminder'
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Recordatorio',
                                      style: TextStyle(
                                        color: _eventType == 'reminder'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() {
                                _eventType = 'appointment';
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _eventType == 'appointment'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      color: _eventType == 'appointment'
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cita',
                                      style: TextStyle(
                                        color: _eventType == 'appointment'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Selección de Mascota
                      const Text(
                        'Mascota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPetId,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.pets),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Selecciona una mascota',
                        ),
                        items: pets.map((pet) {
                          return DropdownMenuItem(
                            value: pet.id,
                            child: Text(pet.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPetId = value);
                        },
                      ),
                      const SizedBox(height: 20),

                      if (_eventType == 'reminder') ...[
                        const Text(
                          'Título',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Ej: Vacuna anual, Comprar pastillas...',
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Tipo de Recordatorio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _reminderType,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'vaccine',
                              child: Text('Vacuna'),
                            ),
                            DropdownMenuItem(
                              value: 'deworm',
                              child: Text('Desparasitación'),
                            ),
                            DropdownMenuItem(
                              value: 'antiflea',
                              child: Text('Antipulgas'),
                            ),
                            DropdownMenuItem(
                              value: 'checkup',
                              child: Text('Chequeo'),
                            ),
                            DropdownMenuItem(
                              value: 'grooming',
                              child: Text('Peluquería'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Otro'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _reminderType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Descripción
                        const Text(
                          'Descripción (opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Detalles adicionales...',
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Clínica',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedClinicId,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.local_hospital),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Selecciona una clínica',
                          ),
                          items: clinics.map((clinic) {
                            return DropdownMenuItem(
                              value: clinic.id,
                              child: Text(clinic.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClinicId = value;
                              if (value != null) {
                                _loadServices(value);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Servicio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedServiceId,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.medical_services),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: _loadingServices
                                ? 'Cargando servicios...'
                                : 'Selecciona un servicio',
                          ),
                          items: _services.map((service) {
                            return DropdownMenuItem(
                              value: service.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(service.name),
                                  if (service.price != null)
                                    Text(
                                      '\$${service.price!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _loadingServices
                              ? null
                              : (value) {
                                  setState(() => _selectedServiceId = value);
                                },
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Notas (opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Agrega notas adicionales...',
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Fecha
                      const Text(
                        'Fecha',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Selecciona una fecha',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Horario
                      if (_eventType == 'appointment')
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hora inicio',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _selectTime,
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.access_time,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _selectedTime != null
                                            ? _selectedTime!.format(context)
                                            : '--:--',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hora fin',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _selectEndTime,
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.access_time,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _endTime != null
                                            ? _endTime!.format(context)
                                            : '--:--',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hora',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectTime,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.access_time),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : '--:--',
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Botones
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      _isSubmitting
                          ? 'Guardando...'
                          : (_eventType == 'appointment'
                                ? 'Crear Cita'
                                : 'Crear Recordatorio'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Diálogo para editar cita existente
