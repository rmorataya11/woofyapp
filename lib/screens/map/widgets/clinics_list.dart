import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme_utils.dart';
import '../../../models/clinic_model.dart';
import 'clinic_card.dart';

class ClinicsList extends ConsumerWidget {
  final List<Clinic> clinics;
  final Function(Clinic) onClinicContactTap;

  const ClinicsList({
    super.key,
    required this.clinics,
    required this.onClinicContactTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clínicas Disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (clinics.isEmpty)
            _buildEmptyState(context, ref)
          else
            ...clinics.map(
              (clinic) => ClinicCard(
                clinic: clinic,
                onContactTap: () => onClinicContactTap(clinic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No se encontraron clínicas cercanas',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

