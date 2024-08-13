import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_android/features/products/domain/domain.dart';
import 'package:teslo_android/features/products/presentation/providers/providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedProductsProvider =
    StateNotifierProvider<SearchedProductNotifier, List<Product>>(
  (ref) {
    final productRepository = ref.read(productsRepositoryProvider);
    return SearchedProductNotifier(
        searchProduct: productRepository.searchProductByTerm, ref: ref);
  },
);

typedef SearchProductsCallback = Future<List<Product>> Function(String query);

class SearchedProductNotifier extends StateNotifier<List<Product>> {
  final SearchProductsCallback searchProduct;
  final Ref ref;
  SearchedProductNotifier({required this.searchProduct, required this.ref})
      : super([]);

  Future<List<Product>> searchProductsByQuery(String query) async {
    final List<Product> products = await searchProduct(query);
    ref.read(searchQueryProvider.notifier).update((state) => query);
    state = products;
    return products;
  }
}
