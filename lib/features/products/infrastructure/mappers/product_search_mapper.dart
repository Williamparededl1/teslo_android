import 'package:teslo_android/config/config.dart';
import 'package:teslo_android/features/products/domain/domain.dart';

class ProductSearchMapper {
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
        images: (json["images"] == [])
            ? []
            : List<String>.from(
                json["images"].map((x) => Image.fromJson(x).url)),
        user: null,
      );
}

class Image {
  final String url;

  Image({
    required this.url,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        url: json["url"].startsWith('http')
            ? json["url"]
            : '${Environment.apiUrl}/files/product/${json["url"]}',
      );
}
