//!1. State del provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_android/features/auth/presentation/providers/providers.dart';
import 'package:teslo_android/features/shared/shared.dart';

//!3. StateNotifier - consume afuera
final registerFormProvider =
    StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>(
        (ref) {
  final registerUserCallBack = ref.watch(authProvider.notifier).registerUser;
  return RegisterFormNotifier(registerUserCallBack: registerUserCallBack);
});

class RegisterFormState {
  final bool isEqualsPassword;
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Email email;
  final Password password;
  final Password confirmPassword;
  final Name name;

  RegisterFormState({
    this.isEqualsPassword = false,
    this.isFormPosted = false,
    this.isPosting = false,
    this.isValid = false,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const Password.pure(),
    this.name = const Name.pure(),
  });

  RegisterFormState copyWith({
    bool? isEqualsPassword,
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
    Password? password,
    Password? confirmPassword,
    Name? name,
  }) =>
      RegisterFormState(
        isEqualsPassword: isEqualsPassword ?? this.isEqualsPassword,
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        name: name ?? this.name,
      );

  @override
  String toString() {
    return '''
          RegisterFormState:
          isEqualsPassword = $isEqualsPassword
          isFormPosted = $isFormPosted
          isPosting = $isPosting
          isValid = $isValid
          email = $email
          password = $password
          confirmPassword = $confirmPassword
          name = $name
            ''';
  }
}

//!2. Como implementamos el notifier

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Function(String, String, String) registerUserCallBack;
  RegisterFormNotifier({required this.registerUserCallBack})
      : super(RegisterFormState());

  onEmailChange(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
        email: newEmail,
        isValid: Formz.validate(
            [newEmail, state.password, state.confirmPassword, state.name]));
  }

  onPasswordChange(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
        password: newPassword,
        isValid: Formz.validate(
            [newPassword, state.email, state.confirmPassword, state.name]));
  }

  onNameChange(String value) {
    final newName = Name.dirty(value);
    state = state.copyWith(
        name: newName,
        isValid: Formz.validate(
            [newName, state.email, state.confirmPassword, state.password]));
  }

  onConfirmPasswordChange(String value) {
    final newConfirmPassword = Password.dirty(value);
    state = state.copyWith(
        confirmPassword: newConfirmPassword,
        isValid: Formz.validate(
            [newConfirmPassword, state.email, state.password, state.name]));
  }

  onFormSubmit() async {
    _touchEveryField();
    _equalsPasswords();

    if (!state.isValid || !state.isEqualsPassword) return;

    await registerUserCallBack(
        state.email.value, state.password.value, state.name.value);
  }

  _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final confirmPassword = Password.dirty(state.confirmPassword.value);
    final name = Name.dirty(state.name.value);

    state = state.copyWith(
        isFormPosted: true,
        email: email,
        password: password,
        name: name,
        confirmPassword: confirmPassword,
        isValid: Formz.validate([email, password, name, confirmPassword]));
  }

  _equalsPasswords() {
    if (state.password.value == state.confirmPassword.value) {
      state = state.copyWith(isEqualsPassword: true);
    } else {
      state = state.copyWith(isEqualsPassword: false);
    }
  }
}
