import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Logged in → start loading this user's favourites and cart
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              !previous.isAuthenticated && current.isAuthenticated,
          listener: (context, state) {
            final userId = state.user!.id;
            context.read<FavoritesBloc>().add(FavoritesStarted(userId));
            context.read<CartBloc>().add(CartStarted(userId));
          },
        ),

        // Logged out → stop listening and empty what's on screen.
        // CartStopped does NOT delete the saved cart in Firestore.
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.isAuthenticated && !current.isAuthenticated,
          listener: (context, state) {
            context.read<CartBloc>().add(const CartStopped());
            context.read<FavoritesBloc>().add(const FavoritesStopped());
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.unknown:
              return const _SplashScreen();
            case AuthStatus.authenticated:
              return const MainNavigation();
            case AuthStatus.unauthenticated:
              return const LoginPage();
          }
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.primaryDark,
            ),
            SizedBox(height: 12),
            Text(
              'ShopMate',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
