import 'package:client/features/auth/login/screens/login_screen.dart';
import 'package:client/features/auth/signup/screens/signup_screen.dart';
import 'package:client/features/profile/screens/profile_screen.dart';
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
        ],
      ),
    ],
  );
}
