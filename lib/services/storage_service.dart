import 'package:hive/hive.dart';

class StorageService {
  final Box _box = Hive.box('authBox');

  Future<void> saveToken(String token) async {
    await _box.put('auth_token', token);
  }

  Future<String?> getToken() async {
    return _box.get('auth_token');
  }

  Future<void> deleteToken() async {
    await _box.delete('auth_token');
  }
}