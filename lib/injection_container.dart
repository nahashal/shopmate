import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'features/assistant/data/repositories/assistant_repository_impl.dart';
import 'features/assistant/domain/repositories/assistant_repository.dart';
import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';

import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/domain/usecases/get_categories.dart';
import 'features/products/domain/usecases/get_products.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'features/orders/data/repositories/order_repository_impl.dart';
import 'features/orders/domain/repositories/order_repository.dart';
import 'features/orders/presentation/bloc/checkout_bloc.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/orders/presentation/bloc/orders_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Assistant
  getIt.registerFactory<AssistantRepository>(
    () => AssistantRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerFactory<OrdersBloc>(() => OrdersBloc(getIt<OrderRepository>()));
  // Orders
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(FirebaseFirestore.instance),
  );
  getIt.registerFactory<CheckoutBloc>(
    () => CheckoutBloc(getIt<OrderRepository>()),
  );
  // Cart
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(FirebaseFirestore.instance),
  );
  getIt.registerFactory<CartBloc>(() => CartBloc(getIt<CartRepository>()));
  // Favorites
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(FirebaseFirestore.instance),
  );
  getIt.registerFactory<FavoritesBloc>(
    () => FavoritesBloc(getIt<FavoritesRepository>()),
  );
  // Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(FirebaseAuth.instance),
  );
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  // Dio client
  getIt.registerLazySingleton<Dio>(() => DioClient.createDio());

  // Remote data source
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Repository
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: getIt<ProductRemoteDataSource>(),
    ),
  );

  // Use case
  getIt.registerLazySingleton<GetProducts>(
    () => GetProducts(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<GetCategories>(
    () => GetCategories(getIt<ProductRepository>()),
  );

  // BLoC
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(
      getProducts: getIt<GetProducts>(),
      getCategories: getIt<GetCategories>(),
    ),
  );
}
