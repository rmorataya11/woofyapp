import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/clinic_model.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/clinic_provider.dart';
import '../../../services/clinic_service.dart';
class NewAppointmentDialog extends ConsumerStatefulWidget {
  final VoidCallback onAppointmentCreated;

  const NewAppointmentDialog({super.key, required this.onAppointmentCreated});

  @override
  ConsumerState<NewAppointmentDialog> createState() =>
      _NewAppointmentDialogState();
}

class _NewAppointmentDialogState extends ConsumerState<NewAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _clinicService = ClinicService();

  String? _selectedPetId;
  String? _selectedClinicId;
  String? _selectedServiceId;
  List<ClinicServiceModel> _services = [];
  bool _loadingServices = false;

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    Future(() {
      ref.read(petNotifierProvider.notifier).loadPets();
      ref.read(clinicProvider.notifier).loadClinics();
    });
  }

  @override
  void dispose() {
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

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
        if (_endTime == null) {
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
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una mascota'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedClinicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una clínica'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un servicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona fecha y horario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final startsAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endsAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final success = await ref
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

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        Navigator.of(context).pop();
        widget.onAppointmentCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la cita'),
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
                  const Icon(Icons.add_circle, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nueva Cita',
                      style: TextStyle(
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
                      // Mascota
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

                      // Clínica
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

                      // Servicio
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
                                  onTap: _selectStartTime,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.access_time),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      _startTime != null
                                          ? _startTime!.format(context)
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
                                      prefixIcon: const Icon(Icons.access_time),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                      ),
                      const SizedBox(height: 20),

                      // Notas
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
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Agrega notas adicionales...',
                        ),
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
                      _isSubmitting ? 'Creando...' : 'Crear Cita',
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

