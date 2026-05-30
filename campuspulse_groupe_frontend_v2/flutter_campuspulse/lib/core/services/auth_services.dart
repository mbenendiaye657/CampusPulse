import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<void> saveUserInfo({
    required String username,
    required String firstName,
    required String lastName,
    required String level,
    required String department,
  }) async {
    await _storage.write(key: 'username',   value: username);
    await _storage.write(key: 'first_name', value: firstName);
    await _storage.write(key: 'last_name',  value: lastName);
    await _storage.write(key: 'level',      value: level);
    await _storage.write(key: 'department', value: department);
  }

  static Future<String?> getToken()      async => _storage.read(key: 'access_token');
  static Future<String?> getUsername()   async => _storage.read(key: 'username');
  static Future<String?> getFirstName()  async => _storage.read(key: 'first_name');
  static Future<String?> getLastName()   async => _storage.read(key: 'last_name');
  static Future<String?> getLevel()      async => _storage.read(key: 'level');
  static Future<String?> getDepartment() async => _storage.read(key: 'department');

  static Future<void> logout() async => _storage.deleteAll();

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
