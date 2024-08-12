import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_android/features/auth/presentation/providers/providers.dart';
import 'package:teslo_android/features/products/domain/domain.dart';
import 'package:teslo_android/features/products/infrastructure/infrastructure.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final accesToken = ref.watch(authProvider).user?.token ?? '';
  final productsRepository = ProductsRepositoryImpl(
      datasource: ProductsDatasourceImpl(accesToken: accesToken));
  return productsRepository;
});
