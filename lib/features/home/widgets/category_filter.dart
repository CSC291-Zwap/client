import 'package:flutter/material.dart';
import 'package:client/core/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryFilterWidget({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((category) {
              final isSelected = category == selected;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: AppTheme.toggleSelectedColor,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => onSelected(category),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
