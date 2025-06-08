import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/widgets/category_filter.dart';
import 'package:client/features/home/widgets/product_card.dart';
import 'package:client/features/home/widgets/search_bar.dart';
// Remove: import 'package:client/data/dummy_items.dart';
import 'package:client/features/home/providers/items_provider.dart'; // <-- Add this
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Invalidate the provider so it refetches when HomeScreen is shown
    ref.invalidate(allItemsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('authBox');
    final token = box.get('auth_token');
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final itemsAsync = ref.watch(allItemsProvider);
    // print('HomeScreen created with token: $token');

    return Scaffold(
      appBar: AppBar(
        title: Text('Zwap'),
        actions: [
          (token == null || token.isEmpty)
              ? IconButton(
                icon: Icon(Icons.login),
                onPressed: () async {
                  // Navigate to Login page
                  context.push('/login');
                },
              )
              : IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () async {
                  if (token is! String || token.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please log in first')),
                    );
                    context.push("/login");
                    return;
                  }
                  context.push('/profile');
                },
              ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBarWidget(),
            SizedBox(height: 12),
            CategoryFilterWidget(
              categories: ['All', 'Electronic', 'Clothes', 'Fashion', 'Others'],
              selected: selectedCategory,
              onSelected:
                  (cat) =>
                      ref.read(selectedCategoryProvider.notifier).state = cat,
            ),
            SizedBox(height: 12),
            Expanded(
              child: itemsAsync.when(
                data:
                    (items) => GridView.builder(
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder:
                          (context, index) => ProductCard(data: items[index]),
                    ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: token is String && token.isNotEmpty,
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () async {
            // Navigate to Add Item page
            await context.push('/add-item');
            ref.invalidate(allItemsProvider); // Refresh items after adding
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
