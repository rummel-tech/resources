import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_services/shared_services.dart';

void main() {
  group('ApiException', () {
    test('should create exception with all properties', () {
      // Arrange & Act
      final exception = ApiException(
        message: 'API error occurred',
        code: 'API_ERROR',
        statusCode: 500,
        responseData: {'detail': 'Internal server error'},
      );

      // Assert
      expect(exception.message, equals('API error occurred'));
      expect(exception.code, equals('API_ERROR'));
      expect(exception.statusCode, equals(500));
      expect(exception.responseData, isNotNull);
      expect(exception.responseData!['detail'], equals('Internal server error'));
      expect(exception.toString(), contains('API error occurred'));
    });

    test('should create from HTTP response with JSON', () {
      // Arrange
      final response = http.Response(
        json.encode({
          'detail': 'Resource not found',
          'error_code': 'NOT_FOUND'
        }),
        404,
      );

      // Act
      final exception = ApiException.fromResponse(response);

      // Assert
      expect(exception.statusCode, equals(404));
      expect(exception.message, equals('Resource not found'));
      expect(exception.code, equals('API_404'));
      expect(exception.responseData, isNotNull);
      expect(exception.responseData!['error_code'], equals('NOT_FOUND'));
    });

    test('should handle response with message field', () {
      // Arrange
      final response = http.Response(
        json.encode({'message': 'Validation failed'}),
        422,
      );

      // Act
      final exception = ApiException.fromResponse(response);

      // Assert
      expect(exception.message, equals('Validation failed'));
      expect(exception.statusCode, equals(422));
    });

    test('should handle malformed JSON response', () {
      // Arrange
      final response = http.Response(
        'Not valid JSON',
        500,
      );

      // Act
      final exception = ApiException.fromResponse(response);

      // Assert
      expect(exception.statusCode, equals(500));
      expect(exception.message, contains('HTTP 500'));
      expect(exception.code, equals('API_500'));
    });

    test('should handle empty response body', () {
      // Arrange
      final response = http.Response('', 204);

      // Act
      final exception = ApiException.fromResponse(response);

      // Assert
      expect(exception.statusCode, equals(204));
      expect(exception.message, contains('HTTP 204'));
    });

    test('should have PARSE_ERROR code', () {
      // Arrange & Act
      final exception = ApiException(
        message: 'Failed to parse response',
        code: 'PARSE_ERROR',
        statusCode: 200,
      );

      // Assert
      expect(exception.code, equals('PARSE_ERROR'));
      expect(exception.message, equals('Failed to parse response'));
    });
  });

  group('AuthException', () {
    test('should create unauthorized exception', () {
      // Act
      final exception = AuthException.unauthorized();

      // Assert
      expect(exception.code, equals('UNAUTHORIZED'));
      expect(exception.message, contains('logged in'));
      expect(exception.toString(), contains('logged in'));
    });

    test('should create invalid credentials exception', () {
      // Act
      final exception = AuthException.invalidCredentials();

      // Assert
      expect(exception.code, equals('INVALID_CREDENTIALS'));
      expect(exception.message, equals('Invalid email or password'));
    });

    test('should create token expired exception', () {
      // Act
      final exception = AuthException.tokenExpired();

      // Assert
      expect(exception.code, equals('TOKEN_EXPIRED'));
      expect(exception.message, contains('Session expired'));
    });

    test('should create registration failed exception with custom message', () {
      // Act
      final exception = AuthException.registrationFailed('Email already exists');

      // Assert
      expect(exception.code, equals('REGISTRATION_FAILED'));
      expect(exception.message, contains('Email already exists'));
    });

    test('should create custom auth exception', () {
      // Act
      final exception = AuthException(
        'Custom auth error',
        code: 'CUSTOM_ERROR',
      );

      // Assert
      expect(exception.message, equals('Custom auth error'));
      expect(exception.code, equals('CUSTOM_ERROR'));
    });
  });

  group('NetworkException', () {
    test('should create connection failed exception', () {
      // Act
      final exception = NetworkException.connectionFailed();

      // Assert
      expect(exception.code, equals('CONNECTION_FAILED'));
      expect(exception.message, contains('Unable to connect to server'));
      expect(exception.toString(), contains('Unable to connect to server'));
    });

    test('should create timeout exception', () {
      // Act
      final exception = NetworkException.timeout();

      // Assert
      expect(exception.code, equals('TIMEOUT'));
      expect(exception.message, contains('Request timed out'));
    });

    test('should create host lookup failed exception', () {
      // Act
      final exception = NetworkException.hostLookupFailed();

      // Assert
      expect(exception.code, equals('HOST_LOOKUP_FAILED'));
      expect(exception.message, contains('Unable to resolve'));
    });

    test('should create custom network exception', () {
      // Act
      final exception = NetworkException('Custom network error');

      // Assert
      expect(exception.message, equals('Custom network error'));
      expect(exception.code, equals('NETWORK_ERROR'));
    });
  });

  group('ValidationException', () {
    test('should create validation exception with single field error', () {
      // Act
      final exception = ValidationException.field('email', 'Invalid email format');

      // Assert
      expect(exception.message, equals('Invalid email format'));
      expect(exception.code, equals('FIELD_VALIDATION_ERROR'));
      expect(exception.fieldErrors, hasLength(1));
      expect(exception.fieldErrors!['email'], equals('Invalid email format'));
    });

    test('should create validation exception with multiple field errors', () {
      // Act
      final exception = ValidationException.fields({
        'email': 'Email is required',
        'password': 'Password must be at least 8 characters',
        'name': 'Name cannot be empty',
      });

      // Assert
      expect(exception.code, equals('MULTIPLE_FIELD_ERRORS'));
      expect(exception.fieldErrors, hasLength(3));
      expect(exception.fieldErrors!['email'], equals('Email is required'));
      expect(exception.fieldErrors!['password'], equals('Password must be at least 8 characters'));
      expect(exception.fieldErrors!['name'], equals('Name cannot be empty'));
    });

    test('should create custom validation exception', () {
      // Act
      final exception = ValidationException(
        'General validation error',
        code: 'CUSTOM_VALIDATION',
      );

      // Assert
      expect(exception.message, equals('General validation error'));
      expect(exception.code, equals('CUSTOM_VALIDATION'));
    });
  });

  group('AppException', () {
    test('should be base class for all exceptions', () {
      // Act & Assert
      expect(ApiException(message: 'test', code: 'TEST'), isA<AppException>());
      expect(AuthException('test', code: 'TEST'), isA<AppException>());
      expect(NetworkException('test'), isA<AppException>());
      expect(
        ValidationException('test'),
        isA<AppException>(),
      );
    });

    test('should have common properties', () {
      // Act
      final exception = AuthException(
        'Test message',
        code: 'TEST_CODE',
      );

      // Assert
      expect(exception.message, equals('Test message'));
      expect(exception.code, equals('TEST_CODE'));
    });

    test('should support toString', () {
      // Act
      final exception = NetworkException.timeout();

      // Assert
      expect(exception.toString(), isNotEmpty);
      expect(exception.toString(), contains('NetworkException'));
      expect(exception.toString(), contains('Request timed out'));
    });
  });

  group('Exception hierarchy', () {
    test('should catch AppException for any exception type', () {
      // Arrange
      void throwException() {
        throw ApiException(message: 'API error', code: 'ERROR');
      }

      // Act & Assert
      expect(
        () => throwException(),
        throwsA(isA<AppException>()),
      );
    });

    test('should catch specific exception types', () {
      // Arrange
      void throwNetworkException() {
        throw NetworkException.connectionFailed();
      }

      void throwAuthException() {
        throw AuthException.unauthorized();
      }

      // Act & Assert
      expect(
        () => throwNetworkException(),
        throwsA(isA<NetworkException>()),
      );

      expect(
        () => throwAuthException(),
        throwsA(isA<AuthException>()),
      );
    });

    test('should differentiate between exception types in catch blocks', () {
      // Arrange
      String caughtType = '';

      void handleException(Exception e) {
        if (e is AuthException) {
          caughtType = 'auth';
        } else if (e is NetworkException) {
          caughtType = 'network';
        } else if (e is ApiException) {
          caughtType = 'api';
        } else if (e is ValidationException) {
          caughtType = 'validation';
        }
      }

      // Act & Assert
      handleException(AuthException.unauthorized());
      expect(caughtType, equals('auth'));

      handleException(NetworkException.timeout());
      expect(caughtType, equals('network'));

      handleException(ApiException(message: 'error', code: 'ERROR'));
      expect(caughtType, equals('api'));

      handleException(ValidationException('error'));
      expect(caughtType, equals('validation'));
    });
  });

  group('Real-world scenarios', () {
    test('should handle 401 unauthorized response', () {
      // Arrange
      final response = http.Response(
        json.encode({'detail': 'Token has expired'}),
        401,
      );

      // Act
      final exception = ApiException.fromResponse(response);

      // Assert
      expect(exception.statusCode, equals(401));
      expect(exception.message, equals('Token has expired'));
    });

    test('should handle 422 validation response', () {
      // Arrange
      final response = http.Response(
        json.encode({
          'detail': 'Validation Error',
          'errors': [
            {'field': 'email', 'message': 'Invalid format'},
            {'field': 'password', 'message': 'Too short'}
          ]
        }),
        422,
      );

      // Act
      final exception = ApiException.fromResponse(response);

      // Assert
      expect(exception.statusCode, equals(422));
      expect(exception.responseData!['errors'], isA<List>());
    });

    test('should handle 500 internal server error', () {
      // Arrange
      final response = http.Response(
        json.encode({'detail': 'Internal server error'}),
        500,
      );

      // Act
      final exception = ApiException.fromResponse(response);

      // Assert
      expect(exception.statusCode, equals(500));
      expect(exception.message, equals('Internal server error'));
    });

    test('should handle network timeout scenario', () {
      // Act
      final exception = NetworkException.timeout();

      // Assert
      expect(exception.code, equals('TIMEOUT'));
      expect(exception.message, contains('timed out'));
    });

    test('should handle login failure scenario', () {
      // Act
      final exception = AuthException.invalidCredentials();

      // Assert
      expect(exception.code, equals('INVALID_CREDENTIALS'));
      expect(exception.message, contains('Invalid email or password'));
    });

    test('should handle form validation scenario with field errors', () {
      // Act
      final exception = ValidationException.fields({
        'email': 'Email is required',
        'password': 'Password must be at least 8 characters',
        'terms': 'Terms must be accepted',
      });

      // Assert
      expect(exception.fieldErrors, hasLength(3));
      expect(exception.code, equals('MULTIPLE_FIELD_ERRORS'));
    });
  });
}
