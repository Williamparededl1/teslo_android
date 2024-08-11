import 'package:dio/dio.dart';
import 'package:teslo_android/config/config.dart';
import 'package:teslo_android/features/auth/domain/domain.dart';
import 'package:teslo_android/features/auth/infrastructure/infrastructure.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<User> checkAuthStatus(String token) {
    // TODO: implement checkAuthStatus
    throw UnimplementedError();
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio
          .post('/auth/login', data: {'email': email, 'password': password});
      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw WrongCredentials();
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeOut();
      }

      throw CustomError(message: "Something wrong happend", errorCode: 1);
    } catch (e) {
      throw CustomError(message: "Something wrong happend", errorCode: 1);
    }
  }

  @override
  Future<User> register(String email, String password, String fullName) async {
    try {
      final response = await dio.post('/auth/register',
          data: {'email': email, 'password': password, 'fullName': fullName});
      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) throw UserExist();
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeOut();
      }

      throw CustomError(message: "Something wrong happend", errorCode: 1);
    } catch (e) {
      throw CustomError(message: "Something wrong happend", errorCode: 1);
    }
  }
}
