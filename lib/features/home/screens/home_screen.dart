import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/widgets/category_filter.dart';
import 'package:client/features/home/widgets/item_type_toggle.dart';
import 'package:client/features/home/widgets/product_card.dart';
import 'package:client/features/home/widgets/search_bar.dart';
import 'package:client/data/dummy_products.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

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
              selected: selectedCategory,
              onSelected:
                  (cat) =>
                      ref.read(selectedCategoryProvider.notifier).state = cat,
            ),
            SizedBox(height: 12),
            ItemTypeToggleWidget(),
            SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: dummyProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder:
                    (context, index) => ProductCard(data: dummyProducts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
