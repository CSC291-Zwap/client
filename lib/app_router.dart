import 'package:client/features/auth/login/screens/login_screen.dart';
import 'package:client/features/auth/signup/screens/signup_screen.dart';
import 'package:client/features/post_item/screens/add_item_screen.dart';
import 'package:client/features/profile/screens/edit_profile_screen.dart';
import 'package:client/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/screens/home_screen.dart';
import 'features/item_detail/screens/item_detail_screen.dart';
import 'package:client/data/models/item.dart';
import 'package:client/services/api_service_item.dart'; // Add this import

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(),
        routes: [
          GoRoute(
            path: 'item-detail/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';

              // Create a FutureBuilder wrapper widget for async data fetching
              return ItemDetailWrapper(itemId: id);
            },
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => ProfileScreen(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            builder: (context, state) {
              final currentName = state.extra as String? ?? '';
              return EditProfileScreen(currentName: currentName);
            },
          ),
          GoRoute(
            path: 'add-item',
            builder: (context, state) => const AddItemScreen(),
          ),
        ],
      ),
    ],
  );
}

// Wrapper widget to handle async item fetching
class ItemDetailWrapper extends StatefulWidget {
  final String itemId;

  const ItemDetailWrapper({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDetailWrapperState createState() => _ItemDetailWrapperState();
}

class _ItemDetailWrapperState extends State<ItemDetailWrapper> {
  late Future<Item?> _itemFuture;

  @override
  void initState() {
    super.initState();
    _itemFuture = _fetchItemById(widget.itemId);
  }

  Future<Item?> _fetchItemById(String id) async {
    try {
      final api = ItemApiService();
      final result =
          await api
              .getAllItems(); // You might want to create a getItemById method

      if (result['success'] == true) {
        List<dynamic> itemsData = result['data']['data'];

        // Find the item with matching ID
        final itemData = itemsData.firstWhere(
          (item) => item['id'] == id,
          orElse: () => null,
        );

        if (itemData != null) {
          return Item.fromJson(itemData);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching item: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Item?>(
      future: _itemFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading...')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading item: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final item = snapshot.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Item Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Item not found'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return ItemDetailScreen(item: item);
      },
    );
  }
}
