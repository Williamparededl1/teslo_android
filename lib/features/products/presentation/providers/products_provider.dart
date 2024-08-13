import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_android/features/products/domain/domain.dart';
import 'package:teslo_android/features/products/presentation/providers/providers.dart';

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final productRepositoryProvider = ref.watch(productsRepositoryProvider);

  return ProductsNotifier(productsRepository: productRepositoryProvider);
});

final productsSearchProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final productRepositoryProvider = ref.watch(productsRepositoryProvider);

  return ProductsNotifier(productsRepository: productRepositoryProvider);
});

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductsRepository productsRepository;
  ProductsNotifier({required this.productsRepository})
      : super(ProductsState()) {
    loadNextPage();
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final products = await productsRepository.getProductsByPage(
        limit: state.limit, offset: state.offset);
    if (products.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        products: [...state.products, ...products]);
  }

  Future searchPage(String term) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final products = await productsRepository.searchProductByTerm(term);
    if (products.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        products: [...state.products, ...products]);
  }
}

class ProductsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Product> products;

  ProductsState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.products = const []});

  ProductsState copyWith({
    final bool? isLastPage,
    final int? limit,
    final int? offset,
    final bool? isLoading,
    final List<Product>? products,
  }) =>
      ProductsState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        products: products ?? this.products,
      );
}
