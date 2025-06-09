import 'package:flutter/material.dart';

class ProductImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ProductImageCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    print('ProductImageCarousel created with imageUrls: $imageUrls');
    return AspectRatio(
      aspectRatio: 1,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(imageUrls[index], fit: BoxFit.contain);
        },
      ),
    );
  }
}
