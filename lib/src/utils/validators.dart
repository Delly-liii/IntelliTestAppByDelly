import 'package:flutter/material.dart';

typedef Validator = String? Function(String? value);

/// Common form validators for IntelliTest APP
/// Each validator returns null when the value is valid, or a string error message otherwise.

String? requiredValidator(String? value,
    {String message = 'This field is required'}) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? minLengthValidator(String? value, int min, {String? message}) {
  message ??= 'Must be at least $min characters';
  if (value == null || value.trim().length < min) return message;
  return null;
}

String? maxLengthValidator(String? value, int max, {String? message}) {
  message ??= 'Must be at most $max characters';
  if (value != null && value.trim().length > max) return message;
  return null;
}

String? emailValidator(String? value,
    {String message = 'Enter a valid email'}) {
  if (value == null || value.trim().isEmpty) return message;
  final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
  if (!emailRegex.hasMatch(value.trim())) return message;
  return null;
}

String? numericValidator(String? value,
    {String message = 'Enter a valid number'}) {
  if (value == null || value.trim().isEmpty) return message;
  final numValue = num.tryParse(value.trim());
  if (numValue == null) return message;
  return null;
}

String? integerValidator(String? value,
    {String message = 'Enter a valid integer'}) {
  if (value == null || value.trim().isEmpty) return message;
  final intValue = int.tryParse(value.trim());
  if (intValue == null) return message;
  return null;
}

String? positiveIntegerValidator(String? value,
    {String message = 'Enter a positive integer'}) {
  final err = integerValidator(value, message: message);
  if (err != null) return err;
  final v = int.parse(value!.trim());
  if (v < 0) return message;
  return null;
}

String? percentValidator(String? value,
    {String message = 'Enter a percentage between 0 and 100'}) {
  final err = numericValidator(value, message: message);
  if (err != null) return err;
  final v = num.parse(value!.trim());
  if (v < 0 || v > 100) return message;
  return null;
}

String? passwordStrengthValidator(String? value,
    {int minLength = 8, String? message}) {
  message ??=
      'Password must be at least $minLength characters and include letters and numbers';
  if (value == null || value.length < minLength) return message;
  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
  final hasNumber = RegExp(r'\d').hasMatch(value);
  if (!hasLetter || !hasNumber) return message;
  return null;
}

String? matchValidator(String? value, String? otherValue,
    {String message = 'Values do not match'}) {
  if (value != otherValue) return message;
  return null;
}

// Convenience wrappers that return FormFieldValidator<String>

FormFieldValidator<String> requiredField(
        {String message = 'This field is required'}) =>
    (v) => requiredValidator(v, message: message);
FormFieldValidator<String> emailField(
        {String message = 'Enter a valid email'}) =>
    (v) => emailValidator(v, message: message);
FormFieldValidator<String> minLengthField(int min, {String? message}) =>
    (v) => minLengthValidator(v, min, message: message);
FormFieldValidator<String> maxLengthField(int max, {String? message}) =>
    (v) => maxLengthValidator(v, max, message: message);
FormFieldValidator<String> passwordField(
        {int minLength = 8, String? message}) =>
    (v) => passwordStrengthValidator(v, minLength: minLength, message: message);
FormFieldValidator<String> percentField(
        {String message = 'Enter a percentage between 0 and 100'}) =>
    (v) => percentValidator(v, message: message);

// Export common validator functions

// Note: You can import this file and use either the plain functions (which return String?)
// or the FormFieldValidator wrappers for use directly in TextFormField validators.
