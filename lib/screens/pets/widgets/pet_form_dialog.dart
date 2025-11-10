import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/pet_model.dart';

class PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Future<void> Function(Pet) onSave;

  const PetFormDialog({super.key, this.pet, required this.onSave});

  @override
  State<PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageMonthsController = TextEditingController();
  final _weightKgController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  String _vaccinationStatus = 'unknown';

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed;
      _ageMonthsController.text = widget.pet!.ageMonths.toString();
      _weightKgController.text = widget.pet!.weightKg.toString();
      _medicalNotesController.text = widget.pet!.medicalNotes;

      final validStatuses = ['unknown', 'up_to_date', 'in_progress', 'overdue'];
      if (validStatuses.contains(widget.pet!.vaccinationStatus)) {
        _vaccinationStatus = widget.pet!.vaccinationStatus;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageMonthsController.dispose();
    _weightKgController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pet == null ? 'Agregar Mascota' : 'Editar Mascota'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Raza',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La raza es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageMonthsController,
                      decoration: const InputDecoration(
                        labelText: 'Edad (meses)',
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 24',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 0) {
                          return 'Edad inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightKgController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 5.5',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Peso inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _vaccinationStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado de Vacunación',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'unknown',
                    child: Text('Desconocido'),
                  ),
                  DropdownMenuItem(value: 'up_to_date', child: Text('Al día')),
                  DropdownMenuItem(
                    value: 'in_progress',
                    child: Text('En proceso'),
                  ),
                  DropdownMenuItem(value: 'overdue', child: Text('Vencidas')),
                ],
                onChanged: (value) {
                  setState(() {
                    _vaccinationStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalNotesController,
                decoration: const InputDecoration(
                  labelText: 'Notas Médicas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _savePet,
          child: Text(widget.pet == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate()) {
      final pet = Pet(
        id: widget.pet?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        ageMonths: int.parse(_ageMonthsController.text),
        weightKg: double.parse(_weightKgController.text),
        photoUrl: widget.pet?.photoUrl,
        medicalNotes: _medicalNotesController.text.trim(),
        vaccinationStatus: _vaccinationStatus,
        createdAt: widget.pet?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final navigator = Navigator.of(context);

      await widget.onSave(pet);

      if (mounted) {
        navigator.pop();
      }
    }
  }
}
