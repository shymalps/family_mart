import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService extends GetxService {
  late SharedPreferences _prefs;
  final isLoggedInRx = false.obs;

  // Keys
  static const _keyId = 'user_id';
  static const _keyName = 'user_name';
  static const _keyUserType = 'user_type';
  static const _keyEmail = 'user_email';
  static const _keyPhone = 'user_phone';
  static const _keyPassword = 'user_password';

  Future<SharedPreferencesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    isLoggedInRx.value = _prefs.getBool('isLoggedIn') ?? false;
    return this;
  }

  // Save user info
  Future<void> saveUser({
    required int id,
    required String name,
    required String userType,
    required String email,
    required String phone,
    String? password,
  }) async {
    await _prefs.setBool('isLoggedIn', true);
    isLoggedInRx.value = true;
    await _prefs.setInt(_keyId, id);
    await _prefs.setString(_keyName, name);
    await _prefs.setString(_keyUserType, userType);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyPhone, phone);
    if (password != null) {
      await _prefs.setString(_keyPassword, password);
    }
  }

  // Retrieve
  int get userId => _prefs.getInt(_keyId) ?? 0;
  String get userName => _prefs.getString(_keyName) ?? '';
  String get userType => _prefs.getString(_keyUserType) ?? '';
  String get userEmail => _prefs.getString(_keyEmail) ?? '';
  String get userPhone => _prefs.getString(_keyPhone) ?? '';
  String get userPassword => _prefs.getString(_keyPassword) ?? '';

  // Setter for password
  Future<void> setUserPassword(String password) async {
    await _prefs.setString(_keyPassword, password);
  }

  // Clear all on logout
  Future<void> clearUserData() async {
    await _prefs.remove(_keyId);
    await _prefs.remove(_keyName);
    await _prefs.remove(_keyUserType);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyPhone);
    await _prefs.remove(_keyPassword);
    isLoggedInRx.value = false;
  }

  bool get isLoggedIn => userId > 0;
}