import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// StorageService handles persistent token storage for the application using SharedPreferences.
///
/// This service is responsible for:
/// - Saving the authentication token
/// - Retrieving the stored token
/// - Clearing the token on logout
class StorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _fCMtokenKey = 'fcm_token';

  /// Saves the authentication token to persistent storage.
  ///
  /// [token] The JWT or authentication token to be stored.
  /// This token will persist even if the app is closed and reopened.
  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the stored authentication token.
  ///
  /// Returns the stored token as a String, or null if no token is stored.
  /// This is typically used when the app starts to check if a user is already logged in.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Clears the stored authentication token.
  ///
  /// This is typically called when the user logs out or the session expires.
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Saves the authentication token to persistent storage.
  ///
  /// [token] The JWT or authentication token to be stored.
  /// This token will persist even if the app is closed and reopened.
  Future<void> setFCMToken(String token) async {
    await _storage.write(key: _fCMtokenKey, value: token);
  }

  /// Retrieves the stored authentication token.
  ///
  /// Returns the stored token as a String, or null if no token is stored.
  /// This is typically used when the app starts to check if a user is already logged in.
  Future<String?> getFCMToken() async {
    return await _storage.read(key: _fCMtokenKey);
  }
}
