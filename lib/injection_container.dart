import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';

import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';

import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/domain/usecases/get_products.dart';

import 'features/products/presentation/bloc/product_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
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

  // BLoC
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(getProducts: getIt<GetProducts>()),
  );
}
