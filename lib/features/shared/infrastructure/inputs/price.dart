import 'package:formz/formz.dart';

// Define input validation errors
enum PriceError { empty, value }

// Extend FormzInput and provide the input type and error type.
class Price extends FormzInput<double, PriceError> {
  // Call super.pure to represent an unmodified form input.
  const Price.pure() : super.pure(0.0);

  // Call super.dirty to represent a modified form input.
  const Price.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == PriceError.empty) return 'El campo es requerido';
    if (displayError == PriceError.value) return 'tiene ser cero o mayor';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  PriceError? validator(double value) {
    if (value.toString().isEmpty || value.toString().trim().isEmpty) {
      return PriceError.empty;
    }
    if (value < 0) return PriceError.value;

    return null;
  }
}
