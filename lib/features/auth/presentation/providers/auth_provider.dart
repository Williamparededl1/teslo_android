import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_android/features/auth/domain/domain.dart';
import 'package:teslo_android/features/auth/infrastructure/infrastructure.dart';
import 'package:teslo_android/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:teslo_android/features/shared/infrastructure/services/key_value_storage_service_impl.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return AuthNotifier(
      authRepository: authRepository,
      keyValueStorageService: keyValueStorageService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  AuthNotifier(
      {required this.authRepository, required this.keyValueStorageService})
      : super(AuthState()) {
    checkStatusUser();
  }

  Future<void> loginUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final user = await authRepository.login(email, password);

      _setLoggerUser(user);
    } on WrongCredentials {
      logout(errorMessage: 'Credenciales incorrectas');
    } on ConnectionTimeOut {
      logout(errorMessage: 'Conneccion timeout');
    } catch (e) {
      logout(errorMessage: 'Error no controlado');
    }
    //
    // state = state.copyWith(user: user, authStatus: AuthStatus.authenticated);
  }

  Future<void> registerUser(
      String email, String password, String fullName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final user = await authRepository.register(email, password, fullName);

      _setUserCreate(user);
    } on ConnectionTimeOut {
      logout(errorMessage: 'Conneccion timeout');
    } on UserExist {
      logout(errorMessage: 'El Usuario ya Existe');
    } catch (e) {
      logout(errorMessage: 'Error no controlado');
    }
  }

  void checkStatusUser() async {
    final token = await keyValueStorageService.getValue<String>('token');
    if (token == null) return logout();
    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggerUser(user);
    } on InvalidToken {
      logout(errorMessage: 'Token Invalido');
    } on ConnectionTimeOut {
      logout(errorMessage: 'Conneccion timeout');
    } catch (e) {
      logout(errorMessage: 'Error no controlado');
    }
  }

  void _setLoggerUser(User user) async {
    await keyValueStorageService.setKeyValue('token', user.token);
    state = state.copyWith(
        user: user, authStatus: AuthStatus.authenticated, errorMessage: '');
  }

  void _setUserCreate(User user) {
    state = state.copyWith(
        user: null,
        authStatus: AuthStatus.checking,
        errorMessage: 'Usuario Creado Correctamente');
  }

  Future<void> logout({String? errorMessage}) async {
    await keyValueStorageService.removeKey('token');
    state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: errorMessage);
  }
}

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState(
      {this.authStatus = AuthStatus.checking,
      this.user,
      this.errorMessage = ''});

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
          authStatus: authStatus ?? this.authStatus,
          user: user ?? this.user,
          errorMessage: errorMessage ?? this.errorMessage);
}
