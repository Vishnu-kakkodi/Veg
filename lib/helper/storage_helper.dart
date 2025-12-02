import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:veegify/model/user_model.dart';

class UserPreferences {
  static const String _keyUser = 'user';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyRememberMe = 'rememberMe';
  static const String _keyPhoneNumber = 'phoneNumber';
  static const String _keyPassword = 'password';
  static const String _keyUserId = 'userId';


  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Save user data
  static Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _preferences?.setString(_keyUser, userJson);
    await _preferences?.setBool(_keyIsLoggedIn, true);
    await _preferences?.setString(_keyUserId, user.userId); 
  }


  // Get user data
  static User? getUser() {
    final userJson = _preferences?.getString(_keyUser);
    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    }
    return null;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _preferences?.getBool(_keyIsLoggedIn) ?? false;
  }

  // Save remember me preference
  static Future<void> saveRememberMe(bool rememberMe) async {
    await _preferences?.setBool(_keyRememberMe, rememberMe);
  }

  // Get remember me preference
  static bool getRememberMe() {
    return _preferences?.getBool(_keyRememberMe) ?? false;
  }

  // Save phone number (for remember me)
  static Future<void> savePhoneNumber(String phoneNumber) async {
    await _preferences?.setString(_keyPhoneNumber, phoneNumber);
  }

  // Get saved phone number
  static String getSavedPhoneNumber() {
    return _preferences?.getString(_keyPhoneNumber) ?? '';
  }

  // Save password (for remember me) - Note: In production, consider more secure storage
  static Future<void> savePassword(String password) async {
    await _preferences?.setString(_keyPassword, password);
  }

  // Get saved password
  static String getSavedPassword() {
    return _preferences?.getString(_keyPassword) ?? '';
  }

  // Clear all user data (logout)
  static Future<void> clearUserData() async {
    await _preferences?.remove(_keyUser);
    await _preferences?.setBool(_keyIsLoggedIn, false);
    if (!getRememberMe()) {
      await _preferences?.remove(_keyPhoneNumber);
      await _preferences?.remove(_keyPassword);
    }
  }

  // Clear all preferences
  static Future<void> clearAll() async {
    await _preferences?.clear();
  }
}