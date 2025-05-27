import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatelessWidget {
  final Map<String, String> data;

  const ProductCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.go('/', extra: data);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Image.network(data['image']!, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data['title']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${data['price']} Baht',
                    style: TextStyle(color: Colors.green),
                  ),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
