import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/services/api_service_item.dart';
import 'package:client/data/models/item.dart';

final allItemsProvider = FutureProvider<List<Item>>((ref) async {
  final api = ItemApiService();
  final result = await api.getAllItems();

  if (result['success'] == true) {
    List<dynamic> itemsData = result['data']['data'];
    print('Fetched data: $itemsData');

    // Convert raw data to Item objects using fromJson
    List<Item> items =
        itemsData
            .where((item) => item != null)
            .map((item) => Item.fromJson(item))
            .toList();
    // print('Converted ${items.length} items');
    // print('First item: ${items.isNotEmpty ? items[0].title : 'No items'}');

    return items;
  } else {
    throw Exception(result['message'] ?? 'Failed to fetch items');
  }
});
