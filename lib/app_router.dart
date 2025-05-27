import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/screens/home_screen.dart';
import 'features/item_detail/screens/item_detail_screen.dart';
import 'package:client/data/models/item.dart';
import 'package:client/data/dummy_items.dart';

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
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              final item = dummyItems.firstWhere((i) => i.id == id);
              return ItemDetailScreen(item: item);
            },
          ),
        ],
      ),
    ],
  );
}
