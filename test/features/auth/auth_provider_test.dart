import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/auth_service.dart';
import 'package:learning_management_system/services/user_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/providers/user_service_provider.dart';
import 'package:learning_management_system/providers/secure_storage_provider.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockUserService extends Mock implements UserService {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late MockSecureStorage mockStorage;
  late ProviderContainer container;

  // Test data
  const testToken = 'test_token';
  final testUser = User(
    id: 1,
    email: 'test@example.com',
    firstName: 'Nguyen',
    lastName: 'Van A',
    role: 'STUDENT',
    avatar: 'https://example.com/avatar.jpg',
    token: testToken,
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockUserService = MockUserService();
    mockStorage = MockSecureStorage();

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        userServiceProvider.overrideWithValue(mockUserService),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );

    // Setup mock storage methods
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async => {});
    when(() => mockStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async => {});
  });

  tearDown(() {
    container.dispose();
  });

  group('Auth Provider', () {
    test('initial state should be loading', () {
      final authState = container.read(authProvider);
      expect(authState, isA<AsyncLoading<User?>>());
    });

    test('handleSignIn with valid credentials should update state with user', () async {
      // Arrange
      when(() => mockAuthService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => {
        'success': true,
        'message': 'OK',
        'code': '1000',
        'data': {
          'id': 1,
          'ho': 'Nguyen',
          'ten': 'Van A',
          'email': 'test@example.com',
          'role': 'STUDENT',
          'avatar': 'https://example.com/avatar.jpg',
          'token': testToken,
        }
      });

      when(() => mockUserService.getUserInfo(any()))
          .thenAnswer((_) async => testUser);

      // Mock secure storage more specifically
      when(
        () => mockStorage.write(
          key: 'auth_token',
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});

      when(
        () => mockStorage.delete(
          key: 'auth_token',
        ),
      ).thenAnswer((_) async => {});

      // Act
      final result = await container.read(authProvider.notifier).handleSignIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result['success'], true);
      expect(result['code'], '1000');
      
      final authState = container.read(authProvider);
      expect(
        authState.valueOrNull?.email,
        testUser.email,
      );
    });

    test('handleSignIn with unverified user should return verification code', () async {
      // Arrange
      when(() => mockAuthService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => {
        'success': false,
        'needs_verification': true,
        'verify_code': '123456',
      });

      // Act
      final result = await container.read(authProvider.notifier).handleSignIn(
        email: 'unverified@example.com',
        password: 'password123',
      );

      // Assert
      expect(result['needs_verification'], true);
      expect(result['verify_code'], '123456');
    });

    test('handleSignIn with invalid credentials should throw', () async {
      // Arrange
      when(() => mockAuthService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(Exception('Invalid credentials'));

      // Act & Assert
      expect(
        () => container.read(authProvider.notifier).handleSignIn(
          email: 'wrong@example.com',
          password: 'wrong_password',
        ),
        throwsException,
      );
    });

    test('signOut should clear user state', () async {
      // Arrange - First sign in a user
      when(() => mockAuthService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => {
        'success': true,
        'token': testToken,
      });

      when(() => mockUserService.getUserInfo(any()))
          .thenAnswer((_) async => testUser);

      await container.read(authProvider.notifier).handleSignIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Act
      await container.read(authProvider.notifier).signOut();

      // Assert
      final authState = container.read(authProvider);
      expect(authState.valueOrNull, null);
    });
  });
} 