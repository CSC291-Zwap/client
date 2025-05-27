import 'package:flutter/material.dart';
import 'package:client/features/home/widgets/category_filter.dart';
import 'package:client/features/home/widgets/item_type_toggle.dart';
import 'package:client/features/home/widgets/product_card.dart';
import 'package:client/features/home/widgets/search_bar.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> items = List.generate(6, (index) {
    return {
      'title': 'IKEA Clothes Cabinet',
      'price': '2500',
      'image': 'https://www.ikea.com/th/en/images/products/kleppstad-wardrobe-with-3-doors-white__0753594_pe748782_s5.jpg?f=xxs',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zwap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBarWidget(),
            SizedBox(height: 12),
            CategoryFilterWidget(
              categories: ['Electronic', 'Clothes', 'Fashion', 'Others'],
              selected: 'Clothes',
            ),
            SizedBox(height: 12),
            ItemTypeToggleWidget(),
            SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) => ProductCard(data: items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}