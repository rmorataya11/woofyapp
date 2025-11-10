import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme_utils.dart';

class MapFilters extends ConsumerWidget {
  final String selectedFilter;
  final String selectedSort;
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;
  final List<Map<String, dynamic>> filters;

  const MapFilters({
    super.key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.filters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Filtros
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final isSelected = selectedFilter == filter['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter['name'] as String),
                      avatar: Icon(
                        filter['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                      onSelected: (_) => onFilterChanged(filter['id'] as String),
                      selectedColor: const Color(0xFF1E88E5),
                      backgroundColor: ThemeUtils.getCardColor(context, ref),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : ThemeUtils.getTextPrimaryColor(context, ref),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Ordenamiento
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              color: ThemeUtils.getTextPrimaryColor(context, ref),
            ),
            onSelected: onSortChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'distance',
                child: Row(
                  children: [
                    Icon(Icons.near_me, size: 20),
                    SizedBox(width: 8),
                    Text('Distancia'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 8),
                    Text('Rating'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

