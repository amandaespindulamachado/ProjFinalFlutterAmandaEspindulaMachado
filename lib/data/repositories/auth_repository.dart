import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/remote/api_datasource.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/hmac_util.dart';

/// Repositório de autenticação — RF03, RF04
class AuthRepository {
  AuthRepository({
    ApiDatasource? apiDatasource,
    FlutterSecureStorage? secureStorage,
  })  : _api = apiDatasource ?? const ApiDatasource(),
        _storage = secureStorage ?? const FlutterSecureStorage();

  final ApiDatasource _api;
  final FlutterSecureStorage _storage;

  /// Faz login: assina a senha com HMAC-SHA256, chama API e persiste token.
  Future<String> login(String email, String senha) async {
    final senhaHash = HmacUtil.sign(senha);
    final token = await _api.login(email: email, senhaHash: senhaHash);
    await _storage.write(key: AppConstants.tokenKey, value: token);
    await _storage.write(key: AppConstants.userEmailKey, value: email);
    return token;
  }

  /// Retorna o token armazenado, ou null se não existir — RF02
  Future<String?> getSavedToken() async {
    return _storage.read(key: AppConstants.tokenKey);
  }

  /// Remove o token do armazenamento seguro (logout)
  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userEmailKey);
  }

  /// Verifica se existe sessão ativa — RF02
  Future<bool> hasActiveSession() async {
    final token = await getSavedToken();
    return token != null && token.isNotEmpty;
  }
}
