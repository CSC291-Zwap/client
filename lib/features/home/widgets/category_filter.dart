import 'package:flutter/material.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<String> categories;
  final String selected;

  const CategoryFilterWidget({required this.categories, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selected;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Chip(
              label: Text(category),
              backgroundColor: isSelected ? Colors.green : Colors.grey[200],
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }
}