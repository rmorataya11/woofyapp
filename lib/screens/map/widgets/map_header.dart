import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme_utils.dart';

class MapHeader extends ConsumerWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Mapa de Clínicas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
                Text(
                  'Encuentra veterinarias cerca de ti',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
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

