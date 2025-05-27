import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/screens/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [GoRoute(path: '/', builder: (context, state) => HomeScreen())],
  );
}
