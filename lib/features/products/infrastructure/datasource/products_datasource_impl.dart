import 'package:dio/dio.dart';
import 'package:teslo_android/config/config.dart';
import 'package:teslo_android/features/products/domain/domain.dart';
import 'package:teslo_android/features/products/infrastructure/errors/product_errors.dart';
import 'package:teslo_android/features/products/infrastructure/infrastructure.dart';
import 'package:teslo_android/features/products/infrastructure/mappers/product_mapper.dart';
import 'package:teslo_android/features/products/infrastructure/mappers/product_search_mapper.dart';

class ProductsDatasourceImpl extends ProductsDatasource {
  late final Dio dio;
  final String accesToken;

  ProductsDatasourceImpl({required this.accesToken})
      : dio = Dio(BaseOptions(
            baseUrl: Environment.apiUrl,
            headers: {'Authorization': 'Bearer $accesToken'}));

  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productsLike) async {
    try {
      final String? productId = productsLike['id'];
      final String method = (productId == 'new') ? 'POST' : 'PATCH';
      final String url =
          (productId == 'new') ? '/products' : '/products/$productId';
      productsLike.remove('id');
      final response = await dio.request(url,
          data: productsLike, options: Options(method: method));
      final product = ProductMapper.jsonToEntity(response.data);
      return product;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await dio.get('/products/$id');
      final products = ProductMapper.jsonToEntity(response.data);
      return products;
    } on DioException catch (e) {
      if (e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Product>> getProductsByPage(
      {int limit = 10, int offset = 0}) async {
    final response =
        await dio.get<List>('/products?limit=$limit&offset=$offset');
    final List<Product> products = [];
    for (final product in response.data ?? []) {
      products.add(ProductMapper.jsonToEntity(product));
    }
    return products;
  }

  @override
  Future<List<Product>> searchProductByTerm(String term) async {
    try {
      if (term.isEmpty) return [];
      final response = await dio.get<List>('/products/all/$term');
      final List<Product> products = [];
      for (final product in response.data ?? []) {
        products.add(ProductSearchMapper.jsonToEntity(product));
      }
      return products;
    } catch (e) {
      return [];
    }
  }
}
