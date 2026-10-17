import 'package:flutter/foundation.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/chamado_repository.dart';

enum AuthState { idle, loading, success, error }

/// ViewModel de autenticação — RF02, RF03, RF04
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    AuthRepository? authRepository,
    ChamadoRepository? chamadoRepository,
  })  : _auth = authRepository ?? AuthRepository(),
        _chamados = chamadoRepository ?? ChamadoRepository();

  final AuthRepository _auth;
  final ChamadoRepository _chamados;

  AuthState _state = AuthState.idle;
  String _errorMessage = '';
  bool _hasSession = false;

  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  bool get hasSession => _hasSession;
  bool get isLoading => _state == AuthState.loading;

  /// Verifica sessão salva — RF02
  Future<bool> checkSession() async {
    _hasSession = await _auth.hasActiveSession();
    notifyListeners();
    return _hasSession;
  }

  /// Login com HMAC-SHA256 e carga inicial do SQLite — RF03, RF04
  Future<bool> login(String email, String senha) async {
    _setState(AuthState.loading);
    try {
      final token = await _auth.login(email, senha);
      // Carga inicial dos chamados da API para o SQLite — RF04
      try {
        await _chamados.sincronizarChamadosRemoto(token);
      } catch (_) {
        // Falha na carga inicial não impede o login
      }
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(AuthState.error);
      return false;
    }
  }

  /// Recupera token armazenado
  Future<String?> getToken() => _auth.getSavedToken();

  /// Logout
  Future<void> logout() async {
    await _auth.logout();
    _hasSession = false;
    _setState(AuthState.idle);
  }

  void _setState(AuthState s) {
    _state = s;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _state = AuthState.idle;
    notifyListeners();
  }
}
