import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pet_provider.dart';
import '../../config/theme_utils.dart';
import 'package:go_router/go_router.dart';

class PetsScreen extends ConsumerStatefulWidget {
  const PetsScreen({super.key});

  @override
  ConsumerState<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends ConsumerState<PetsScreen> {
  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: ThemeUtils.getBackgroundDecoration(context, ref),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Mis Mascotas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getTextPrimaryColor(context, ref),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showAddPetDialog(),
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).colorScheme.primary,
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: pets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              size: 80,
                              color: ThemeUtils.getTextSecondaryColor(
                                context,
                                ref,
                              ).withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tienes mascotas registradas',
                              style: TextStyle(
                                color: ThemeUtils.getTextSecondaryColor(
                                  context,
                                  ref,
                                ),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _showAddPetDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar tu primera mascota'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pets.length,
                        itemBuilder: (context, index) {
                          return _buildPetCard(pets[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.pets,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getTextPrimaryColor(context, ref),
                      ),
                    ),
                    Text(
                      '${pet.breed} • ${pet.age} años',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                    ),
                    Text(
                      _getVaccinationText(pet.vaccinationStatus),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getVaccinationColor(pet.vaccinationStatus),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditPetDialog(pet);
                  } else if (value == 'delete') {
                    _showDeletePetDialog(pet);
                  } else if (value == 'details') {
                    _showPetDetailsModal(pet);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 18),
                        SizedBox(width: 8),
                        Text('Ver detalles'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: ThemeUtils.getTextSecondaryColor(context, ref),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: ThemeUtils.getTextSecondaryColor(
              context,
              ref,
            ).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.monitor_weight, '${pet.weight} kg'),
              _buildInfoItem(Icons.palette, pet.color),
              _buildInfoItem(
                pet.gender == 'male' ? Icons.male : Icons.female,
                pet.gender == 'male' ? 'Macho' : 'Hembra',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: ThemeUtils.getTextSecondaryColor(context, ref),
          ),
        ),
      ],
    );
  }

  String _getVaccinationText(String status) {
    switch (status) {
      case 'up_to_date':
        return 'Vacunas al día';
      case 'in_progress':
        return 'En proceso';
      case 'overdue':
        return 'Vencidas';
      default:
        return 'Desconocido';
    }
  }

  Color _getVaccinationColor(String status) {
    switch (status) {
      case 'up_to_date':
        return const Color(0xFF4CAF50);
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'overdue':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF616161);
    }
  }

  void _showAddPetDialog() {
    showDialog(
      context: context,
      builder: (context) => _PetFormDialog(
        onSave: (pet) {
          ref.read(petNotifierProvider.notifier).addPet(pet);
        },
      ),
    );
  }

  void _showEditPetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => _PetFormDialog(
        pet: pet,
        onSave: (updatedPet) {
          ref.read(petNotifierProvider.notifier).updatePet(updatedPet);
        },
      ),
    );
  }

  void _showDeletePetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mascota'),
        content: Text('¿Estás seguro de que quieres eliminar a ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(petNotifierProvider.notifier).deletePet(pet.id);
              context.pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPetDetailsModal(Pet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PetDetailsModal(pet: pet, ref: ref),
    );
  }
}

// Pet Form Dialog
class _PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Function(Pet) onSave;

  const _PetFormDialog({this.pet, required this.onSave});

  @override
  State<_PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<_PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  String _gender = 'male';
  String _vaccinationStatus = 'up_to_date';

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed;
      _ageController.text = widget.pet!.age.toString();
      _weightController.text = widget.pet!.weight.toString();
      _colorController.text = widget.pet!.color;
      _medicalNotesController.text = widget.pet!.medicalNotes;
      _gender = widget.pet!.gender;
      _vaccinationStatus = widget.pet!.vaccinationStatus;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _colorController.dispose();
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
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Edad (años)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Género',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Macho')),
                  DropdownMenuItem(value: 'female', child: Text('Hembra')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El color es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _vaccinationStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado de Vacunación',
                  border: OutlineInputBorder(),
                ),
                items: const [
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

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      final pet = Pet(
        id: widget.pet?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        breed: _breedController.text,
        age: int.parse(_ageController.text),
        gender: _gender,
        weight: double.parse(_weightController.text),
        color: _colorController.text,
        medicalNotes: _medicalNotesController.text,
        vaccinationStatus: _vaccinationStatus,
        lastVetVisit: widget.pet?.lastVetVisit ?? DateTime.now(),
        createdAt: widget.pet?.createdAt ?? DateTime.now(),
      );

      widget.onSave(pet);
      context.pop();
    }
  }
}

// Pet Details Modal
class _PetDetailsModal extends StatelessWidget {
  final Pet pet;
  final WidgetRef ref;

  const _PetDetailsModal({required this.pet, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.pets,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getTextPrimaryColor(context, ref),
                      ),
                    ),
                    Text(
                      '${pet.breed} • ${pet.age} años',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Información General', [
                    _buildInfoItem('Raza', pet.breed),
                    _buildInfoItem('Edad', '${pet.age} años'),
                    _buildInfoItem(
                      'Género',
                      pet.gender == 'male' ? 'Macho' : 'Hembra',
                    ),
                    _buildInfoItem('Peso', '${pet.weight} kg'),
                    _buildInfoItem('Color', pet.color),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Estado de Salud', [
                    _buildInfoItem(
                      'Vacunación',
                      _getVaccinationText(pet.vaccinationStatus),
                    ),
                    _buildInfoItem(
                      'Última visita',
                      _formatDate(pet.lastVetVisit),
                    ),
                    _buildInfoItem('Notas médicas', pet.medicalNotes),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF616161),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF212121)),
            ),
          ),
        ],
      ),
    );
  }

  String _getVaccinationText(String status) {
    switch (status) {
      case 'up_to_date':
        return 'Al día';
      case 'in_progress':
        return 'En proceso';
      case 'overdue':
        return 'Vencidas';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
