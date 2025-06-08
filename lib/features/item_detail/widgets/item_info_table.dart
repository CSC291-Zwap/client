import 'package:client/data/models/item.dart';
import 'package:flutter/material.dart';

class ProductInfoTable extends StatelessWidget {
  const ProductInfoTable({super.key, required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        infoRow("Seller", "Thompson"),
        infoRow("Contact No.", "+66 9799521617"),
        infoRow("Pick up location", "Bangkok"),
        infoRow("Product Condition", "7 (barely used)"),
      ],
    );
  }
}

TableRow infoRow(String label, String value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(padding: const EdgeInsets.all(8.0), child: Text(value)),
    ],
  );
}
