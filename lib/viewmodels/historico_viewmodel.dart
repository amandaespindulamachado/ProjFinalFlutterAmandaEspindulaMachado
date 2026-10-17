import 'package:flutter/foundation.dart';
import '../data/models/atendimento_model.dart';
import '../data/repositories/atendimento_repository.dart';
import '../data/repositories/auth_repository.dart';

enum HistoricoState { idle, loading, loaded, syncing, error }

/// ViewModel do histórico — RF13, RF14, RF15, RF16
class HistoricoViewModel extends ChangeNotifier {
  HistoricoViewModel({
    AtendimentoRepository? atendimentoRepository,
    AuthRepository? authRepository,
  })  : _atendimentos = atendimentoRepository ?? AtendimentoRepository(),
        _auth = authRepository ?? AuthRepository();

  final AtendimentoRepository _atendimentos;
  final AuthRepository _auth;

  HistoricoState _state = HistoricoState.idle;
  String _errorMessage = '';
  String _mensagemSync = '';
  List<AtendimentoModel> _todos = [];
  List<AtendimentoModel> _filtrados = [];
  String _queryFiltro = '';

  HistoricoState get state => _state;
  String get errorMessage => _errorMessage;
  String get mensagemSync => _mensagemSync;
  List<AtendimentoModel> get atendimentos => _filtrados;
  bool get isLoading =>
      _state == HistoricoState.loading || _state == HistoricoState.syncing;
  bool get hasPendentes => _todos.any((a) => a.isPendente);
  int get totalPendentes => _todos.where((a) => a.isPendente).length;

  /// Carrega histórico local — RF14
  Future<void> carregarHistorico() async {
    _setState(HistoricoState.loading);
    try {
      _todos = await _atendimentos.getAllLocais();
      _aplicarFiltro();
      _setState(HistoricoState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(HistoricoState.error);
    }
  }

  /// Filtro em tempo real por ID ou código — RF15
  void filtrar(String query) {
    _queryFiltro = query;
    _aplicarFiltro();
    notifyListeners();
  }

  void _aplicarFiltro() {
    _filtrados = _atendimentos.filtrar(_todos, _queryFiltro);
  }

  /// Sincroniza pendentes com a nuvem — RF13
  Future<void> sincronizar() async {
    _setState(HistoricoState.syncing);
    try {
      final token = await _auth.getSavedToken();
      if (token == null) throw Exception('Sessão expirada. Faça login novamente.');

      final count = await _atendimentos.sincronizarPendentes(token);
      _mensagemSync = count > 0
          ? '$count atendimento(s) sincronizado(s) com sucesso!'
          : 'Nenhum novo atendimento para sincronizar.';

      // Recarrega lista após sync
      _todos = await _atendimentos.getAllLocais();
      _aplicarFiltro();
      _setState(HistoricoState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(HistoricoState.error);
    }
  }

  void clearMensagem() {
    _mensagemSync = '';
    notifyListeners();
  }

  void _setState(HistoricoState s) {
    _state = s;
    notifyListeners();
  }
}
