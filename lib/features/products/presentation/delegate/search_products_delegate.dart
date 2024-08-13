import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:teslo_android/features/products/domain/domain.dart';

typedef SearchProductCallback = Future<List<Product>> Function(String term);

class SearchProductsDelegate extends SearchDelegate<Product?> {
  final SearchProductCallback searchProduct;
  List<Product> initialProducts;
  StreamController<List<Product>> debounceProduct =
      StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();
  Timer? _debounceTimer;

  SearchProductsDelegate(
      {required this.searchProduct, required this.initialProducts});

  void _onQueryChanged(String query) {
    isLoadingStream.add(true);
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        final products = await searchProduct(query);
        debounceProduct.add(products);
        initialProducts = products;
        isLoadingStream.add(false);
      },
    );
  }

  void clearStraems() {
    debounceProduct.close();
  }

  Widget builResultsAndSuggestion() {
    return StreamBuilder(
      initialData: initialProducts,
      stream: debounceProduct.stream,
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
        return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) => _ProductItem(
                  product: products[index],
                  onProductSelected: (context, product) {
                    clearStraems();
                    close(context, product);
                  },
                ));
      },
    );
  }

  @override
  String get searchFieldLabel => 'Buscar Producto';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data ?? false) {
            return SpinPerfect(
              duration: const Duration(seconds: 10),
              spins: 10,
              infinite: true,
              child: IconButton(
                  onPressed: () => query = '', icon: const Icon(Icons.refresh)),
            );
          }
          return FadeIn(
            animate: query.isNotEmpty,
            child: IconButton(
                onPressed: () => query = '', icon: const Icon(Icons.clear)),
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          clearStraems();
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return builResultsAndSuggestion();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return builResultsAndSuggestion();
  }
}

class _ProductItem extends StatelessWidget {
  final Product product;
  final Function onProductSelected;
  const _ProductItem({
    required this.product,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        onProductSelected(context, product);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            SizedBox(
              width: size.width * 0.4,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  product.images.first,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) =>
                      FadeIn(child: child),
                ),
              ),
            ),
            const SizedBox(
              width: 3,
            ),
            SizedBox(
              width: size.width * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: textStyle.titleLarge?.copyWith(fontSize: 15),
                  ),
                  Text(
                    product.gender,
                    style: textStyle.titleSmall?.copyWith(fontSize: 15),
                  ),
                  Text(
                    '\$ ${product.price} ',
                    style: textStyle.bodyMedium,
                  ),
                  _Sizeds(
                    producto: product,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Sizeds extends StatelessWidget {
  final Product producto;
  const _Sizeds({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Wrap(
        children: [
          ...producto.sizes.map((sizes) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: Chip(
                  label: Text(sizes),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ))
        ],
      ),
    );
  }
}
