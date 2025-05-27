import 'package:client/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'core/app_theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zwap',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
