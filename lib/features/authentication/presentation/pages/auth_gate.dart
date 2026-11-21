import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/main_navigation.dart';
import '../../../addresses/presentation/bloc/address_bloc.dart';
import '../../../addresses/presentation/bloc/address_event.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'splash_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const _minimumSplashTime = Duration(milliseconds: 1800);

  bool _splashTimeDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_minimumSplashTime, () {
      if (mounted) setState(() => _splashTimeDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Logged in → load this user's data
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              !previous.isAuthenticated && current.isAuthenticated,
          listener: (context, state) {
            final userId = state.user!.id;
            context.read<FavoritesBloc>().add(FavoritesStarted(userId));
            context.read<CartBloc>().add(CartStarted(userId));
            context.read<AddressBloc>().add(AddressesStarted(userId));
          },
        ),

        // Logged out → stop listening and empty what's on screen.
        // Nothing is deleted from Firestore.
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.isAuthenticated && !current.isAuthenticated,
          listener: (context, state) {
            context.read<CartBloc>().add(const CartStopped());
            context.read<FavoritesBloc>().add(const FavoritesStopped());
            context.read<AddressBloc>().add(const AddressesStopped());
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _screenFor(state),
          );
        },
      ),
    );
  }

  Widget _screenFor(AuthState state) {
    if (!_splashTimeDone || state.status == AuthStatus.unknown) {
      return const SplashPage();
    }

    return state.isAuthenticated ? const MainNavigation() : const LoginPage();
  }
}
