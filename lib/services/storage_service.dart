import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey ='auth_userId';
  Future<void> saveToken(String token) async {
    print('Debug - StorageService - Saving token: $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    final savedToken = await prefs.getString(_tokenKey);
    print('Debug - StorageService - Verification of saved token: $savedToken');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('Debug - StorageService - Retrieved token: $token');
    return token;
  } 
   Future<void> saveUserId(String userId) async {
    print('Debug - StorageService - Saving userId: $userId');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    final savedUserId = await prefs.getString(_userIdKey);
    print('Debug - StorageService - Verification of saved userId: $savedUserId');
  }

  /// Retrieve the userId from shared preferences.
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    print('Debug - StorageService - Retrieved userId: $userId');
    return userId;
  }

  Future<void> clearToken() async {
    print('Debug - StorageService - Clearing token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
