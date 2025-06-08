import 'package:client/data/models/item.dart';
import 'package:client/features/home/providers/items_provider.dart';
import 'package:client/services/api_service_item.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuyNowButton extends ConsumerStatefulWidget {
  final Item item;

  const BuyNowButton({super.key, required this.item});
  @override
  ConsumerState<BuyNowButton> createState() => _BuyNowButtonState();
}

class _BuyNowButtonState extends ConsumerState<BuyNowButton> {
  bool _isLoading = false;

  Future<void> _buyNow(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have bought ${widget.item.title}!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _isLoading = true;
    });
    final _apiService = ItemApiService();
    try {
      final result = await _apiService.deleteItem(widget.item.id.toString());

      if (result['success']) {
        if (mounted) {
          ref.invalidate(allItemsProvider);
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to buy item'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error buying item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _buyNow(context),
        icon: const Icon(Icons.shopping_cart_checkout),
        label:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text("Buy Now"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
