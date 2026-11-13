import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/main_navigation.dart';
import 'injection_container.dart';

void main() {
  setupDependencies();
  runApp(const ShopMateApp());
}

class ShopMateApp extends StatelessWidget {
  const ShopMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopMate',
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
