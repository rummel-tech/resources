import 'app_exception.dart';

/// Exception for validation errors
class ValidationException extends AppException {
  @override
  final String message;

  @override
  final String code;

  /// Map of field names to error messages
  final Map<String, String>? fieldErrors;

  ValidationException(
    this.message, {
    this.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  /// Factory for single field error
  factory ValidationException.field(String field, String error) => ValidationException(
    error,
    code: 'FIELD_VALIDATION_ERROR',
    fieldErrors: {field: error},
  );

  /// Factory for multiple field errors
  factory ValidationException.fields(Map<String, String> errors) => ValidationException(
    'Validation failed for ${errors.length} field(s)',
    code: 'MULTIPLE_FIELD_ERRORS',
    fieldErrors: errors,
  );
}
