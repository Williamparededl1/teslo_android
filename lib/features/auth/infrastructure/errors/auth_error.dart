class ConnectionTimeOut implements Exception {}

class WrongCredentials implements Exception {}

class InvaledToken implements Exception {}

class UserExist implements Exception {}

class CustomError implements Exception {
  final String message;
  final int errorCode;

  CustomError({required this.message, required this.errorCode});
}
