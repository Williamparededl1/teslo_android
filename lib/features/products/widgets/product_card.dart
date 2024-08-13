import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teslo_android/features/products/domain/domain.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _ImagenViewer(
          images: product.images,
        ),
        const SizedBox(
          height: 3,
        ),
        Text(product.title),
        const SizedBox(
          height: 20,
        ),
        Text(
          '\$ ${product.price} ',
        )
      ],
    );
  }
}

class _ImagenViewer extends StatelessWidget {
  final List<String> images;
  const _ImagenViewer({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/no-image.jpg',
          fit: BoxFit.cover,
          height: 250,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: FadeInImage(
        fit: BoxFit.cover,
        height: 250,
        fadeOutDuration: const Duration(milliseconds: 100),
        fadeInDuration: const Duration(milliseconds: 200),
        image: NetworkImage(images.first),
        placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
      ),
    );
  }
}
