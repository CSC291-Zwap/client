import 'package:flutter/material.dart';

class ProductImageCarousel extends StatelessWidget {
  final String imageUrl;

  const ProductImageCarousel({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PageView(
        children: [
          Image.network(imageUrl, fit: BoxFit.contain),
          // Add more images here for a real carousel
        ],
      ),
    );
  }
}
