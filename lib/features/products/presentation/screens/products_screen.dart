import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_android/features/auth/presentation/providers/providers.dart';
import 'package:teslo_android/features/products/domain/domain.dart';
import 'package:teslo_android/features/products/presentation/delegate/search_products_delegate.dart';
import 'package:teslo_android/features/products/presentation/providers/providers.dart';
import 'package:teslo_android/features/products/widgets/widgets.dart';
import 'package:teslo_android/features/shared/shared.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final userprovider = ref.watch(authProvider);
    return Scaffold(
      drawer: SideMenu(
        scaffoldKey: scaffoldKey,
        nombre: userprovider.user!.fullName,
      ),
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
              onPressed: () {
                final searchProduct = ref.read(searchedProductsProvider);
                final searchQuery = ref.read(searchQueryProvider);
                showSearch<Product?>(
                        query: searchQuery,
                        context: context,
                        delegate: SearchProductsDelegate(
                            initialProducts: searchProduct,
                            searchProduct: ref
                                .read(searchedProductsProvider.notifier)
                                .searchProductsByQuery))
                    .then((product) {
                  if (product == null) return;
                  context.push('/product/${product.id}');
                });
              },
              icon: const Icon(Icons.search_rounded))
        ],
      ),
      body: const _ProductsView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo producto'),
        icon: const Icon(Icons.add),
        onPressed: () => context.push('/product/new'),
      ),
    );
  }
}

class _ProductsView extends ConsumerStatefulWidget {
  const _ProductsView();

  @override
  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends ConsumerState {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    scrollController.addListener(
      () async {
        if ((scrollController.position.pixels + 400) >=
            scrollController.position.maxScrollExtent) {
          await Future.delayed(const Duration(seconds: 3));
          ref.read(productsProvider.notifier).loadNextPage();
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MasonryGridView.count(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 35,
        itemCount: productState.products.length,
        itemBuilder: (context, index) {
          final product = productState.products[index];
          return GestureDetector(
              onTap: () => context.push('/product/${product.id}'),
              child: ProductCard(product: product));
        },
      ),
    );
  }
}
