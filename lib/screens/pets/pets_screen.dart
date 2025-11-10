import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../config/theme_utils.dart';
import 'widgets/pet_form_dialog.dart';
import 'widgets/pet_details_modal.dart';

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
                      onPressed: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        await ref.read(petNotifierProvider.notifier).refresh();
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Lista actualizada'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      color: Theme.of(context).colorScheme.primary,
                      iconSize: 24,
                    ),
                    IconButton(
                      onPressed: () => _showAddPetDialog(),
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).colorScheme.primary,
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
              _buildStatsSection(),
              const SizedBox(height: 16),
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
                      '${pet.breed} • ${pet.ageYears} ${pet.ageYears == 1 ? "año" : "años"} (${pet.ageMonths} meses)',
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
              _buildInfoItem(Icons.monitor_weight, '${pet.weightKg} kg'),
              _buildInfoItem(Icons.calendar_today, '${pet.ageYears} años'),
              _buildInfoItem(
                Icons.vaccines,
                _getVaccinationText(pet.vaccinationStatus),
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
      builder: (dialogContext) => PetFormDialog(
        onSave: (pet) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final success = await ref
              .read(petNotifierProvider.notifier)
              .addPet(pet);

          if (mounted) {
            if (success) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Mascota agregada correctamente'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            } else {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Error al agregar mascota'),
                  backgroundColor: Color(0xFFF44336),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditPetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (dialogContext) => PetFormDialog(
        pet: pet,
        onSave: (updatedPet) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final success = await ref
              .read(petNotifierProvider.notifier)
              .updatePet(updatedPet);

          if (mounted) {
            if (success) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Mascota actualizada correctamente'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            } else {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Error al actualizar mascota'),
                  backgroundColor: Color(0xFFF44336),
                ),
              );
            }
          }
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final success = await ref
                  .read(petNotifierProvider.notifier)
                  .deletePet(pet.id);

              if (mounted) {
                navigator.pop();

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${pet.name} eliminada correctamente'),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar mascota'),
                      backgroundColor: Color(0xFFF44336),
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

  void _showPetDetailsModal(Pet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PetDetailsModal(pet: pet, ref: ref),
    );
  }

  Widget _buildStatsSection() {
    final pets = ref.watch(petNotifierProvider);
    final tipsList = _getPersonalizedTips(pets);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
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
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Consejos para tus mascotas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeUtils.getTextPrimaryColor(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tipsList.map((tip) => _buildTipCard(tip)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPersonalizedTips(List<Pet> pets) {
    if (pets.isEmpty) {
      return [
        {
          'icon': Icons.pets,
          'title': 'Agrega tu primera mascota',
          'description':
              'Comienza registrando a tu perrito para recibir consejos personalizados.',
          'color': const Color(0xFF1E88E5),
        },
      ];
    }

    final tips = <Map<String, dynamic>>[];

    final avgAge =
        pets.fold<int>(0, (sum, pet) => sum + pet.ageMonths) ~/ pets.length;
    if (avgAge < 12) {
      tips.add({
        'icon': Icons.child_care,
        'title': 'Cachorros en casa',
        'description':
            'Los cachorros necesitan 3-4 comidas al día. Asegúrate de tener un horario consistente.',
        'color': const Color(0xFF9C27B0),
      });
    } else if (avgAge > 84) {
      tips.add({
        'icon': Icons.favorite,
        'title': 'Cuidado senior',
        'description':
            'Los perros mayores necesitan chequeos veterinarios cada 6 meses. Mantén su rutina estable.',
        'color': const Color(0xFFFF9800),
      });
    } else {
      tips.add({
        'icon': Icons.fitness_center,
        'title': 'Mantén la actividad',
        'description':
            'Los perros adultos necesitan 30-60 minutos de ejercicio diario para mantenerse saludables.',
        'color': const Color(0xFF4CAF50),
      });
    }

    final needsVaccination = pets.any(
      (p) =>
          p.vaccinationStatus == 'overdue' ||
          p.vaccinationStatus == 'in_progress',
    );
    if (needsVaccination) {
      tips.add({
        'icon': Icons.vaccines,
        'title': 'Vacunación pendiente',
        'description':
            'Algunas mascotas tienen vacunas pendientes. Agenda una cita con tu veterinario.',
        'color': const Color(0xFFF44336),
      });
    } else {
      tips.add({
        'icon': Icons.water_drop,
        'title': 'Hidratación',
        'description':
            'Asegúrate de que tu perro tenga agua fresca disponible en todo momento.',
        'color': const Color(0xFF2196F3),
      });
    }

    return tips;
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (tip['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (tip['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              tip['icon'] as IconData,
              color: tip['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
