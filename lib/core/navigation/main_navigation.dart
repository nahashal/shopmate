import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/favorites/presentation/bloc/favorites_state.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/bloc/cart_state.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../widgets/shopmate_bottom_nav.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../features/products/presentation/bloc/product_event.dart';
import '../../injection_container.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(const ProductFetchRequested()),
      child: const HomePage(),
    ),
    CartPage(onStartShopping: () => _onItemSelected(0)),
    FavoritesPage(onStartShopping: () => _onItemSelected(0)),
    const ProfilePage(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesBloc, FavoritesState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: BlocSelector<CartBloc, CartState, int>(
          selector: (state) => state.itemCount,
          builder: (context, cartCount) {
            return ShopMateBottomNav(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
              cartCount: cartCount,
            );
          },
        ),
      ),
    );
  }
}
