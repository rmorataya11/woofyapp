import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme_utils.dart';

class AppointmentStatsCards extends ConsumerWidget {
  final Map<String, int> stats;

  const AppointmentStatsCards({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              ref,
              'Total',
              stats['total'].toString(),
              Icons.event,
              const Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              ref,
              'Próximas',
              (stats['scheduled']! + stats['confirmed']!).toString(),
              Icons.schedule,
              const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              ref,
              'Completadas',
              stats['done'].toString(),
              Icons.check_circle,
              const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeUtils.getTextPrimaryColor(context, ref),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: ThemeUtils.getTextSecondaryColor(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

