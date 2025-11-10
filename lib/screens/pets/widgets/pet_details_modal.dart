import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/pet_model.dart';
import '../../../config/theme_utils.dart';

class PetDetailsModal extends StatelessWidget {
  final Pet pet;
  final WidgetRef ref;

  const PetDetailsModal({super.key, required this.pet, required this.ref});

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
                      '${pet.breed} • ${pet.ageYears} años (${pet.ageMonths} meses)',
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
                    _buildInfoItem(
                      'Edad',
                      '${pet.ageYears} ${pet.ageYears == 1 ? "año" : "años"} (${pet.ageMonths} meses)',
                    ),
                    _buildInfoItem('Peso', '${pet.weightKg} kg'),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Estado de Salud', [
                    _buildInfoItem(
                      'Vacunación',
                      _getVaccinationText(pet.vaccinationStatus),
                    ),
                    _buildInfoItem(
                      'Notas médicas',
                      pet.medicalNotes.isNotEmpty
                          ? pet.medicalNotes
                          : 'Sin notas',
                    ),
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
}
