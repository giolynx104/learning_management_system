import 'package:shared_preferences/shared_preferences.dart';

/// StorageService handles persistent token storage for the application using SharedPreferences.
///
/// This service is responsible for:
/// - Saving the authentication token
/// - Retrieving the stored token
/// - Clearing the token on logout
class StorageService {
  // Static key for storing the token - private to prevent external modification
  static const String _tokenKey = 'auth_token';

  /// Saves the authentication token to persistent storage.
  ///
  /// [token] The JWT or authentication token to be stored.
  /// This token will persist even if the app is closed and reopened.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Retrieves the stored authentication token.
  ///
  /// Returns the stored token as a String, or null if no token is stored.
  /// This is typically used when the app starts to check if a user is already logged in.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Clears the stored authentication token.
  ///
  /// This is typically called when the user logs out or the session expires.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
