import 'package:teslo_android/config/constant/environment.dart';
import 'package:teslo_android/features/auth/infrastructure/mappers/user_mapper.dart';

import 'package:teslo_android/features/products/domain/domain.dart';

class ProductMapper {
  static jsonToEntity(Map<String, dynamic> json) => Product(
        id: json['id'],
        title: json['title'],
        price: double.parse(json['price'].toString()),
        description: json['description'],
        slug: json['slug'],
        stock: json['stock'],
        sizes: List<String>.from(json['sizes'].map((size) => size)),
        gender: json['gender'],
        tags: List<String>.from(json['tags'].map((tags) => tags)),
        images: List<String>.from(json['images'].map((String img) =>
            img.startsWith('http')
                ? img
                : '${Environment.apiUrl}/files/product/$img')),
        user: UserMapper.userJsonToEntity(json['user']),
      );
}
