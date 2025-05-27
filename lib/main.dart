import 'package:client/features/home/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'app_router.dart';

void main() => runApp(ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zwap',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
