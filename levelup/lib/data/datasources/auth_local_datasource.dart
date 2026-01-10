import 'package:hive/hive.dart';

import 'local_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> setAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> setUserId(String userId);
  Future<String?> getUserId();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Box<dynamic> get _prefsBox => Hive.box(HiveLocalStorage.prefsBoxName);

  @override
  Future<void> setAuthToken(String token) async {
    await _prefsBox.put(_tokenKey, token);
  }

  @override
  Future<String?> getAuthToken() async {
    final value = _prefsBox.get(_tokenKey);
    return value is String ? value : null;
  }

  @override
  Future<void> setUserId(String userId) async {
    await _prefsBox.put(_userIdKey, userId);
  }

  @override
  Future<String?> getUserId() async {
    final value = _prefsBox.get(_userIdKey);
    return value is String ? value : null;
  }

  @override
  Future<void> clearSession() async {
    await _prefsBox.delete(_tokenKey);
    await _prefsBox.delete(_userIdKey);
  }
}


