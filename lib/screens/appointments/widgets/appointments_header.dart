import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme_utils.dart';

class AppointmentsHeader extends ConsumerWidget {
  final VoidCallback onCalendarTap;

  const AppointmentsHeader({
    super.key,
    required this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.event_note,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mis Citas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
            ),
          ),
          IconButton(
            onPressed: onCalendarTap,
            icon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

