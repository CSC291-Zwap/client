import 'package:flutter/material.dart';
import 'package:client/data/models/item.dart';
import 'package:client/features/item_detail/widgets/item_image_carousel.dart';
import 'package:client/features/item_detail/widgets/item_info_table.dart';
import 'package:client/features/item_detail/widgets/buy_now_button.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    print('ItemDetailScreen created with item: ${item.image}');
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageCarousel(imageUrl: item.image),
            const SizedBox(height: 16),

            _TitleAndPrice(title: item.title, price: item.price),
            const SizedBox(height: 12),

            Text(
              item.description ??
                  "Barely used product, bought a few months ago. Already have a similar product.",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            ProductInfoTable(item: item),
            const SizedBox(height: 24),

            const BuyNowButton(),
          ],
        ),
      ),
    );
  }
}

class _TitleAndPrice extends StatelessWidget {
  final String title;
  final int price;

  const _TitleAndPrice({required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '$price Baht',
          style: const TextStyle(fontSize: 18, color: Colors.green),
        ),
      ],
    );
  }
}
