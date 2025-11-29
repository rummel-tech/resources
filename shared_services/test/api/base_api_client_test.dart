import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_services/shared_services.dart';

import 'base_api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late ApiConfig config;
  late BaseApiClient apiClient;

  setUp(() {
    mockClient = MockClient();
    config = ApiConfig(
      baseUrl: 'https://api.test.com',
      timeout: const Duration(seconds: 5),
      maxRetries: 3,
      enableDebugLogs: false,
    );
    apiClient = BaseApiClient(
      config: config,
      httpClient: mockClient,
    );
  });

  tearDown(() {
    apiClient.dispose();
  });

  group('GET requests', () {
    test('should successfully fetch data', () async {
      // Arrange
      final responseBody = {'id': '123', 'name': 'Test User'};
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            json.encode(responseBody),
            200,
            headers: {'content-type': 'application/json'},
          ));

      // Act
      final result = await apiClient.get<Map<String, dynamic>>(
        '/users/123',
        fromJson: (json) => json,
      );

      // Assert
      expect(result, equals(responseBody));
      verify(mockClient.get(
        Uri.parse('https://api.test.com/users/123'),
        headers: anyNamed('headers'),
      )).called(1);
    });

    test('should add query parameters correctly', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            json.encode({'data': []}),
            200,
          ));

      // Act
      await apiClient.get<Map<String, dynamic>>(
        '/users',
        queryParameters: {'page': '1', 'limit': '10'},
        fromJson: (json) => json,
      );

      // Assert
      verify(mockClient.get(
        Uri.parse('https://api.test.com/users?page=1&limit=10'),
        headers: anyNamed('headers'),
      )).called(1);
    });

    test('should include authorization header when token provider is set', () async {
      // Arrange
      apiClient.tokenProvider = () async => 'test-token';
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            json.encode({}),
            200,
          ));

      // Act
      await apiClient.get<Map<String, dynamic>>(
        '/protected',
        fromJson: (json) => json,
      );

      // Assert
      final captured = verify(mockClient.get(
        any,
        headers: captureAnyNamed('headers'),
      )).captured;
      final headers = captured[0] as Map<String, String>;
      expect(headers['Authorization'], equals('Bearer test-token'));
    });

    test('should throw ApiException on 404', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            json.encode({'detail': 'Not found'}),
            404,
          ));

      // Act & Assert
      expect(
        () => apiClient.get<Map<String, dynamic>>(
          '/nonexistent',
          fromJson: (json) => json,
        ),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.message, 'message', 'Not found')),
      );
    });

    test('should throw NetworkException on connection failure', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenThrow(const SocketException('No connection'));

      // Act & Assert
      expect(
        () => apiClient.get<Map<String, dynamic>>(
          '/users',
          fromJson: (json) => json,
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should throw NetworkException on timeout', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 10));
        return http.Response('{}', 200);
      });

      // Act & Assert
      expect(
        () => apiClient.get<Map<String, dynamic>>(
          '/slow',
          fromJson: (json) => json,
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should retry on 500 server error', () async {
      // Arrange
      var callCount = 0;
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async {
        callCount++;
        if (callCount < 3) {
          return http.Response('Internal Server Error', 500);
        }
        return http.Response(json.encode({'status': 'ok'}), 200);
      });

      // Act
      final result = await apiClient.get<Map<String, dynamic>>(
        '/flaky',
        fromJson: (json) => json,
      );

      // Assert
      expect(result, equals({'status': 'ok'}));
      expect(callCount, equals(3));
    });

    test('should not retry on 400 client error', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            json.encode({'detail': 'Bad request'}),
            400,
          ));

      // Act & Assert
      await expectLater(
        apiClient.get<Map<String, dynamic>>(
          '/bad',
          fromJson: (json) => json,
        ),
        throwsA(isA<ApiException>()),
      );

      // Should only be called once (no retry)
      verify(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).called(1);
    });
  });

  group('POST requests', () {
    test('should successfully post data', () async {
      // Arrange
      final requestBody = {'email': 'test@example.com', 'password': 'secret'};
      final responseBody = {'id': '123', 'email': 'test@example.com'};

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            json.encode(responseBody),
            201,
          ));

      // Act
      final result = await apiClient.post<Map<String, dynamic>>(
        '/auth/register',
        body: requestBody,
        fromJson: (json) => json,
      );

      // Assert
      expect(result, equals(responseBody));
      final captured = verify(mockClient.post(
        Uri.parse('https://api.test.com/auth/register'),
        headers: anyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;
      expect(json.decode(captured[0]), equals(requestBody));
    });

    test('should send correct Content-Type header', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      // Act
      await apiClient.post<Map<String, dynamic>>(
        '/data',
        body: {'key': 'value'},
        fromJson: (json) => json,
      );

      // Assert
      final captured = verify(mockClient.post(
        any,
        headers: captureAnyNamed('headers'),
        body: anyNamed('body'),
      )).captured;
      final headers = captured[0] as Map<String, String>;
      expect(headers['Content-Type'], equals('application/json'));
      expect(headers['Accept'], equals('application/json'));
    });

    test('should handle POST with null body', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      // Act
      await apiClient.post<Map<String, dynamic>>(
        '/endpoint',
        fromJson: (json) => json,
      );

      // Assert
      final captured = verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;
      expect(captured[0], isNull);
    });
  });

  group('PUT requests', () {
    test('should successfully update data', () async {
      // Arrange
      final requestBody = {'name': 'Updated Name'};
      final responseBody = {'id': '123', 'name': 'Updated Name'};

      when(mockClient.put(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            json.encode(responseBody),
            200,
          ));

      // Act
      final result = await apiClient.put<Map<String, dynamic>>(
        '/users/123',
        body: requestBody,
        fromJson: (json) => json,
      );

      // Assert
      expect(result, equals(responseBody));
    });
  });

  group('DELETE requests', () {
    test('should successfully delete resource', () async {
      // Arrange
      when(mockClient.delete(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            json.encode({'message': 'Deleted'}),
            200,
          ));

      // Act
      final result = await apiClient.delete<Map<String, dynamic>>(
        '/users/123',
        fromJson: (json) => json,
      );

      // Assert
      expect(result, equals({'message': 'Deleted'}));
    });

    test('deleteNoResponse should succeed on 204', () async {
      // Arrange
      when(mockClient.delete(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('', 204));

      // Act & Assert
      await expectLater(
        apiClient.deleteNoResponse('/users/123'),
        completes,
      );
    });

    test('deleteNoResponse should throw on error status', () async {
      // Arrange
      when(mockClient.delete(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            json.encode({'error': 'Not found'}),
            404,
          ));

      // Act & Assert
      await expectLater(
        apiClient.deleteNoResponse('/users/999'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('Error handling', () {
    test('should parse API error from response', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            json.encode({
              'detail': 'Validation failed',
              'errors': ['Invalid email']
            }),
            422,
          ));

      // Act & Assert
      try {
        await apiClient.get<Map<String, dynamic>>(
          '/validate',
          fromJson: (json) => json,
        );
        fail('Should have thrown ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, equals(422));
        expect(e.message, equals('Validation failed'));
        expect(e.responseData, isNotNull);
        expect(e.responseData!['errors'], isA<List>());
      }
    });

    test('should handle malformed JSON in error response', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            'Not valid JSON',
            500,
          ));

      // Act & Assert
      await expectLater(
        apiClient.get<Map<String, dynamic>>(
          '/broken',
          fromJson: (json) => json,
        ),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.message, 'message', contains('HTTP 500'))),
      );
    });

    test('should handle malformed JSON in success response', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            'Not valid JSON',
            200,
          ));

      // Act & Assert
      await expectLater(
        apiClient.get<Map<String, dynamic>>(
          '/broken-success',
          fromJson: (json) => json,
        ),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'PARSE_ERROR')
            .having((e) => e.message, 'message', 'Failed to parse response')),
      );
    });
  });

  group('Custom headers', () {
    test('should merge custom headers with default headers', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      // Act
      await apiClient.get<Map<String, dynamic>>(
        '/endpoint',
        headers: {'X-Custom-Header': 'custom-value'},
        fromJson: (json) => json,
      );

      // Assert
      final captured = verify(mockClient.get(
        any,
        headers: captureAnyNamed('headers'),
      )).captured;
      final headers = captured[0] as Map<String, String>;
      expect(headers['X-Custom-Header'], equals('custom-value'));
      expect(headers['Content-Type'], equals('application/json'));
    });

    test('should allow custom headers to override defaults', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      // Act
      await apiClient.get<Map<String, dynamic>>(
        '/endpoint',
        headers: {'Content-Type': 'text/plain'},
        fromJson: (json) => json,
      );

      // Assert
      final captured = verify(mockClient.get(
        any,
        headers: captureAnyNamed('headers'),
      )).captured;
      final headers = captured[0] as Map<String, String>;
      expect(headers['Content-Type'], equals('text/plain'));
    });
  });

  group('Full URL support', () {
    test('should handle full URL instead of endpoint', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      // Act
      await apiClient.get<Map<String, dynamic>>(
        'https://external-api.com/data',
        fromJson: (json) => json,
      );

      // Assert
      verify(mockClient.get(
        Uri.parse('https://external-api.com/data'),
        headers: anyNamed('headers'),
      )).called(1);
    });
  });
}
