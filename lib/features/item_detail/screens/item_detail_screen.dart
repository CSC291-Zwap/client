import 'package:client/app_router.dart';
import 'package:client/features/home/providers/items_provider.dart';
import 'package:client/features/item_detail/screens/edit_item_screen.dart';
import 'package:client/services/api_service_item.dart';
import 'package:flutter/material.dart';
import 'package:client/data/models/item.dart';
import 'package:client/features/item_detail/widgets/item_image_carousel.dart';
import 'package:client/features/item_detail/widgets/item_info_table.dart';
import 'package:client/features/item_detail/widgets/buy_now_button.dart';
import 'package:hive/hive.dart';
import 'package:client/features/item_detail/providers/edit_item_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final Item item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  // Option 1: Use nullable type instead of late
  Item? _item;

  // Option 2: If you prefer to keep late, add null check
  // late Item _item;

  @override
  void initState() {
    super.initState();
    // Add null check to prevent late init error
    if (widget.item != null) {
      _item = widget.item;
    } else {
      // Handle the case where item is null
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Item not found'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  final ItemApiService _apiService = ItemApiService();
  bool _isLoading = false;

  bool get _isOwner {
    if (_item == null) return false;
    final box = Hive.box('authBox');
    final localUserId = box.get('user_id');
    return localUserId != null &&
        localUserId.toString() == _item!.userId.toString();
  }

  Future<void> _deleteItem() async {
    if (_item == null) return;

    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.deleteItem(_item!.id.toString());

      if (result['success']) {
        if (mounted) {
          ref.invalidate(allItemsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Item deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete item'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: $e'),
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

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Item'),
              content: const Text(
                'Are you sure you want to delete this item? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _editItem() async {
    if (_item == null) return;

    final updatedItem = await Navigator.of(context).push<Item>(
      MaterialPageRoute(builder: (context) => EditItemScreen(item: _item!)),
    );
    if (updatedItem != null && mounted) {
      setState(() {
        _item = updatedItem;
      });
      ref.invalidate(allItemsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ItemDetailScreen created with item: ${widget.item}');

    // Add null check for _item
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Detail')),
        body: const Center(child: Text('Item not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_item!.title),
        actions:
            _isOwner
                ? [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editItem();
                          break;
                        case 'delete':
                          _deleteItem();
                          break;
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ]
                : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductImageCarousel(
                      imageUrls:
                          _item!.images.isNotEmpty ? _item!.images : <String>[],
                    ),
                    const SizedBox(height: 16),
                    _TitleAndPrice(title: _item!.title, price: _item!.price),
                    const SizedBox(height: 12),
                    Text(
                      _item!.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProductInfoTable(item: widget.item),
                    const SizedBox(height: 24),
                    if (!_isOwner) BuyNowButton(item: widget.item),
                    if (_isOwner)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _editItem,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Item'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _deleteItem,
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Delete Item',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          '$price Baht',
          style: const TextStyle(fontSize: 18, color: Colors.green),
        ),
      ],
    );
  }
}
