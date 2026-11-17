import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/bloc/cart_state.dart';
import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'injection_container.dart';

void main() {
  setupDependencies();
  runApp(const ShopMateApp());
}

class ShopMateApp extends StatelessWidget {
  const ShopMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ShopMate',
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
      ),
    );
  }
}
