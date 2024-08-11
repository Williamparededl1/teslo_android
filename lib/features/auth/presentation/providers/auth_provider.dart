import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_android/features/auth/domain/domain.dart';
import 'package:teslo_android/features/auth/infrastructure/infrastructure.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  return AuthNotifier(authRepository: authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  AuthNotifier({required this.authRepository}) : super(AuthState());

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

  void registerUser(String email, String password, String fullName) async {
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

  void checkStatusUser(String token) async {
    await authRepository.checkAuthStatus(token);
  }

  void _setLoggerUser(User user) {
    //todo: guardar el token Fisicamente
    state = state.copyWith(
        user: user, authStatus: AuthStatus.authenticated, errorMessage: '');
  }

  void _setUserCreate(User user) {
    //todo: guardar el token Fisicamente
    state = state.copyWith(
        user: null,
        authStatus: AuthStatus.checking,
        errorMessage: 'Usuario Creado Correctamente');
  }

  Future<void> logout({String? errorMessage}) async {
    // todo limpiar token
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
