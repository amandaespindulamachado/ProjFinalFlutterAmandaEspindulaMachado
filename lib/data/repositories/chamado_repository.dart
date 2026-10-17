import '../datasources/local/database_helper.dart';
import '../datasources/remote/api_datasource.dart';
import '../models/chamado_model.dart';
import '../../core/constants/app_constants.dart';

/// Repositório de chamados — RF04, RF05, RF06, RF12
class ChamadoRepository {
  ChamadoRepository({
    DatabaseHelper? dbHelper,
    ApiDatasource? apiDatasource,
  })  : _db = dbHelper ?? DatabaseHelper.instance,
        _api = apiDatasource ?? const ApiDatasource();

  final DatabaseHelper _db;
  final ApiDatasource _api;

  /// Busca chamados da API e salva no SQLite local — RF04
  Future<void> sincronizarChamadosRemoto(String token) async {
    final chamados = await _api.fetchChamados(token);
    // Usa where/map para filtrar apenas os válidos antes de persistir
    final validos = chamados.where((c) => c.id > 0).toList();
    await _db.insertOrReplaceChamados(validos);
  }

  /// Retorna chamados abertos do banco local — RF06 (offline-first)
  Future<List<ChamadoModel>> getChamadosAbertosLocais() async {
    return _db.getChamadosAbertos();
  }

  /// Busca chamado específico pelo ID — RF09
  Future<ChamadoModel?> getChamadoById(int id) async {
    return _db.getChamadoById(id);
  }

  /// Atualiza status do chamado para 'atendido' — RF12
  Future<void> marcarComoAtendido(int chamadoId) async {
    await _db.updateChamadoStatus(chamadoId, AppConstants.statusAtendido);
  }

  /// Verifica se há chamados no banco local (para indicador offline)
  Future<bool> hasChamadosLocais() async {
    final lista = await _db.getChamadosAbertos();
    return lista.isNotEmpty;
  }
}
