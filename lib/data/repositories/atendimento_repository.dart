import '../datasources/local/database_helper.dart';
import '../datasources/remote/api_datasource.dart';
import '../models/atendimento_model.dart';

/// Repositório de atendimentos — RF12, RF13, RF14
class AtendimentoRepository {
  AtendimentoRepository({
    DatabaseHelper? dbHelper,
    ApiDatasource? apiDatasource,
  })  : _db = dbHelper ?? DatabaseHelper.instance,
        _api = apiDatasource ?? const ApiDatasource();

  final DatabaseHelper _db;
  final ApiDatasource _api;

  /// Grava atendimento localmente com flag pendente — RF12
  Future<int> salvarLocalmente(AtendimentoModel atendimento) async {
    return _db.insertAtendimento(atendimento);
  }

  /// Retorna todos os atendimentos do banco local — RF14
  Future<List<AtendimentoModel>> getAllLocais() async {
    return _db.getAllAtendimentos();
  }

  /// Retorna atendimentos pendentes de envio — RF13
  Future<List<AtendimentoModel>> getPendentes() async {
    return _db.getAtendimentosPendentes();
  }

  /// Sincroniza todos os atendimentos pendentes com a API — RF13
  /// Retorna quantos foram sincronizados com sucesso.
  Future<int> sincronizarPendentes(String token) async {
    final pendentes = await _db.getAtendimentosPendentes();
    int count = 0;

    for (final atendimento in pendentes) {
      try {
        final remoto = await _api.uploadAtendimento(token, atendimento);
        await _db.markAtendimentoSincronizado(
          atendimento.id!,
          fotoUrl: remoto.fotoUrl,
        );
        count++;
      } catch (_) {
        // Mantém pendente para próxima tentativa
      }
    }
    return count;
  }

  /// Verifica se há pendências de sincronização
  Future<bool> hasPendentes() async {
    final lista = await getPendentes();
    return lista.isNotEmpty;
  }

  /// Conta atendimentos pendentes
  Future<int> countPendentes() async {
    final lista = await getPendentes();
    return lista.length;
  }

  /// Filtra lista de atendimentos por ID ou código de cliente — RF15
  List<AtendimentoModel> filtrar(
    List<AtendimentoModel> lista,
    String query,
  ) {
    if (query.isEmpty) return lista;
    final q = query.toLowerCase();
    return lista.where((a) {
      return a.chamadoId.toString().contains(q) ||
          a.codigoCliente.toLowerCase().contains(q);
    }).toList();
  }
}
