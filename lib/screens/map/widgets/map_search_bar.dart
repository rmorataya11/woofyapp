import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme_utils.dart';

class MapSearchBar extends ConsumerWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const MapSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar clínicas...',
          hintStyle: TextStyle(
            color: ThemeUtils.getTextSecondaryColor(context, ref),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: ThemeUtils.getTextSecondaryColor(context, ref),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: ThemeUtils.getCardColor(context, ref),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(
          color: ThemeUtils.getTextPrimaryColor(context, ref),
        ),
      ),
    );
  }
}

