import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_services/storage/token_storage.dart';

import 'token_storage_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    tokenStorage = TokenStorage(storage: mockSecureStorage);
  });

  group('saveTokens', () {
    test('should save access and refresh tokens securely', () async {
      // Arrange
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await tokenStorage.saveTokens(
        accessToken: 'test-access-token',
        refreshToken: 'test-refresh-token',
      );

      // Assert
      verify(mockSecureStorage.write(
        key: 'access_token',
        value: 'test-access-token',
      )).called(1);

      verify(mockSecureStorage.write(
        key: 'refresh_token',
        value: 'test-refresh-token',
      )).called(1);
    });
  });

  group('getAccessToken', () {
    test('should retrieve access token', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'stored-access-token');

      // Act
      final token = await tokenStorage.getAccessToken();

      // Assert
      expect(token, equals('stored-access-token'));
      verify(mockSecureStorage.read(key: 'access_token')).called(1);
    });

    test('should return null when no access token exists', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      // Act
      final token = await tokenStorage.getAccessToken();

      // Assert
      expect(token, isNull);
    });
  });

  group('getRefreshToken', () {
    test('should retrieve refresh token', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'stored-refresh-token');

      // Act
      final token = await tokenStorage.getRefreshToken();

      // Assert
      expect(token, equals('stored-refresh-token'));
      verify(mockSecureStorage.read(key: 'refresh_token')).called(1);
    });

    test('should return null when no refresh token exists', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => null);

      // Act
      final token = await tokenStorage.getRefreshToken();

      // Assert
      expect(token, isNull);
    });
  });

  group('hasTokens', () {
    test('should return true when both tokens exist', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'access-token');
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh-token');

      // Act
      final hasTokens = await tokenStorage.hasTokens();

      // Assert
      expect(hasTokens, isTrue);
    });

    test('should return false when access token is missing', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh-token');

      // Act
      final hasTokens = await tokenStorage.hasTokens();

      // Assert
      expect(hasTokens, isFalse);
    });

    test('should return true when access token exists (even if refresh token is missing)', () async {
      // Arrange - hasTokens() only checks for access token
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'access-token');

      // Act
      final hasTokens = await tokenStorage.hasTokens();

      // Assert
      expect(hasTokens, isTrue);
    });

    test('should return false when both tokens are missing', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => null);

      // Act
      final hasTokens = await tokenStorage.hasTokens();

      // Assert
      expect(hasTokens, isFalse);
    });

    test('should return false when tokens are empty strings', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => '');
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => '');

      // Act
      final hasTokens = await tokenStorage.hasTokens();

      // Assert
      expect(hasTokens, isFalse);
    });
  });

  group('saveUserInfo', () {
    test('should save user ID and email', () async {
      // Arrange
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      // Act
      await tokenStorage.saveUserInfo(
        userId: 'user-123',
        email: 'test@example.com',
      );

      // Assert
      verify(mockSecureStorage.write(
        key: 'user_id',
        value: 'user-123',
      )).called(1);

      verify(mockSecureStorage.write(
        key: 'email',
        value: 'test@example.com',
      )).called(1);
    });

    test('should update existing user info', () async {
      // Arrange
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      await tokenStorage.saveUserInfo(
        userId: 'old-user-id',
        email: 'old@example.com',
      );

      // Act
      await tokenStorage.saveUserInfo(
        userId: 'new-user-id',
        email: 'new@example.com',
      );

      // Assert - Verify the most recent calls have the new values
      verify(mockSecureStorage.write(
        key: 'user_id',
        value: 'new-user-id',
      )).called(1);

      verify(mockSecureStorage.write(
        key: 'email',
        value: 'new@example.com',
      )).called(1);
    });
  });

  group('getUserId', () {
    test('should retrieve user ID', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'user_id'))
          .thenAnswer((_) async => 'stored-user-id');

      // Act
      final userId = await tokenStorage.getUserId();

      // Assert
      expect(userId, equals('stored-user-id'));
      verify(mockSecureStorage.read(key: 'user_id')).called(1);
    });

    test('should return null when no user ID exists', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'user_id'))
          .thenAnswer((_) async => null);

      // Act
      final userId = await tokenStorage.getUserId();

      // Assert
      expect(userId, isNull);
    });
  });

  group('getEmail', () {
    test('should retrieve email', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'email'))
          .thenAnswer((_) async => 'stored@example.com');

      // Act
      final email = await tokenStorage.getEmail();

      // Assert
      expect(email, equals('stored@example.com'));
      verify(mockSecureStorage.read(key: 'email')).called(1);
    });

    test('should return null when no email exists', () async {
      // Arrange
      when(mockSecureStorage.read(key: 'email'))
          .thenAnswer((_) async => null);

      // Act
      final email = await tokenStorage.getEmail();

      // Assert
      expect(email, isNull);
    });
  });

  group('clear', () {
    test('should clear all tokens and user info', () async {
      // Arrange
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      // Act
      await tokenStorage.clear();

      // Assert
      verify(mockSecureStorage.delete(key: 'access_token')).called(1);
      verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
      verify(mockSecureStorage.delete(key: 'user_id')).called(1);
      verify(mockSecureStorage.delete(key: 'email')).called(1);
    });

    test('should succeed even when no data exists', () async {
      // Arrange
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      // Act & Assert
      await expectLater(
        tokenStorage.clear(),
        completes,
      );
    });
  });

  group('Error handling', () {
    test('should handle secure storage write errors gracefully', () async {
      // Arrange
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenThrow(Exception('Storage unavailable'));

      // Act & Assert
      await expectLater(
        tokenStorage.saveTokens(
          accessToken: 'token1',
          refreshToken: 'token2',
        ),
        throwsException,
      );
    });

    test('should handle secure storage read errors gracefully', () async {
      // Arrange
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenThrow(Exception('Storage unavailable'));

      // Act & Assert
      await expectLater(
        tokenStorage.getAccessToken(),
        throwsException,
      );
    });

    test('should handle secure storage delete errors gracefully', () async {
      // Arrange
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenThrow(Exception('Storage unavailable'));

      // Act & Assert
      await expectLater(
        tokenStorage.clear(),
        throwsException,
      );
    });
  });

  group('Token persistence', () {
    test('should persist tokens across storage instances', () async {
      // Arrange
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'persisted-access');
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'persisted-refresh');

      // Act
      await tokenStorage.saveTokens(
        accessToken: 'persisted-access',
        refreshToken: 'persisted-refresh',
      );

      // Create new instance
      final newStorage = TokenStorage(storage: mockSecureStorage);
      final accessToken = await newStorage.getAccessToken();
      final refreshToken = await newStorage.getRefreshToken();

      // Assert
      expect(accessToken, equals('persisted-access'));
      expect(refreshToken, equals('persisted-refresh'));
    });
  });
}
