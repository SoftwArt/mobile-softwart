import '../../core/utils/token_storage.dart';

class AuthLocalDataSource {
  Future<void> saveToken(String token) async {
    await TokenStorage.saveToken(token);
  }

  Future<String?> getToken() async {
    return await TokenStorage.getToken();
  }

  Future<void> deleteToken() async {
    await TokenStorage.deleteToken();
  }

  Future<bool> hasValidToken() async {
    return await TokenStorage.hasValidToken();
  }
}
