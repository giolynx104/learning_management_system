import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class StorageService {
  static const String _tokenKey = 'user_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  // Save complete user data
  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_tokenKey, user.token),
      prefs.setString(_userRoleKey, user.role),
      prefs.setInt(_userIdKey, user.id),
      prefs.setString(_userDataKey, jsonEncode(user.toJson())),
    ]);
  }

  // Get complete user data
  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    
    if (userDataString != null) {
      try {
        return User.fromJson(jsonDecode(userDataString));
      } catch (e) {
        // If there's an error parsing the data, clear it
        await clearUserSession();
        return null;
      }
    }
    return null;
  }

  // Keep existing methods but mark them as @deprecated
  @deprecated
  Future<void> saveUserSession({
    required String token,
    required String role,
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_userRoleKey, role),
      prefs.setInt(_userIdKey, userId),
    ]);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userRoleKey),
      prefs.remove(_userIdKey),
      prefs.remove(_userDataKey),
    ]);
  }
}
