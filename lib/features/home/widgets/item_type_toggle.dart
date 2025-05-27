import 'package:flutter/material.dart';
import 'package:client/core/app_theme.dart';

class ItemTypeToggleWidget extends StatefulWidget {
  @override
  State<ItemTypeToggleWidget> createState() => _ItemTypeToggleWidgetState();
}

class _ItemTypeToggleWidgetState extends State<ItemTypeToggleWidget> {
  int selectedIndex = 0;
  final List<String> options = ['Single Item', 'Bulk Item'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SegmentedButton<int>(
        segments: [
          ButtonSegment(value: 0, label: Text(options[0])),
          ButtonSegment(value: 1, label: Text(options[1])),
        ],
        selected: <int>{selectedIndex},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            selectedIndex = newSelection.first;
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (states) =>
                states.contains(MaterialState.selected)
                    ? AppTheme.toggleSelectedColor
                    : AppTheme.toggleUnselectedColor,
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>(
            (states) =>
                states.contains(MaterialState.selected)
                    ? AppTheme.toggleSelectedTextColor
                    : AppTheme.toggleUnselectedTextColor,
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        showSelectedIcon: false,
      ),
    );
  }
}
