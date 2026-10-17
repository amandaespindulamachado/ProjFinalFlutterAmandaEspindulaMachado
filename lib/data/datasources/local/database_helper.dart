import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../models/chamado_model.dart';
import '../../models/atendimento_model.dart';
import '../../../core/constants/app_constants.dart';

/// Camada de persistência local SQLite — RF05
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de chamados (Ordens de Serviço)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableChamados} (
        id            INTEGER PRIMARY KEY,
        codigo_cliente TEXT NOT NULL,
        nome_cliente   TEXT NOT NULL,
        categoria      TEXT NOT NULL,
        resumo_problema TEXT NOT NULL,
        endereco       TEXT NOT NULL,
        cidade         TEXT NOT NULL,
        estado         TEXT NOT NULL,
        latitude       REAL NOT NULL DEFAULT 0.0,
        longitude      REAL NOT NULL DEFAULT 0.0,
        status         TEXT NOT NULL DEFAULT 'aberto',
        data_criacao   TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Tabela de atendimentos realizados
    await db.execute('''
      CREATE TABLE ${AppConstants.tableAtendimentos} (
        id                    INTEGER PRIMARY KEY AUTOINCREMENT,
        chamado_id            INTEGER NOT NULL,
        codigo_cliente        TEXT NOT NULL,
        categoria_tecnica     TEXT NOT NULL,
        descricao_procedimento TEXT NOT NULL,
        data_conclusao        TEXT NOT NULL,
        foto_caminho          TEXT,
        foto_url              TEXT,
        sincronizado          INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (chamado_id) REFERENCES ${AppConstants.tableChamados}(id)
      )
    ''');
  }

  // ── CHAMADOS ────────────────────────────────────────────────────────────────

  /// Insere ou substitui lista de chamados (carga inicial da API — RF04)
  Future<void> insertOrReplaceChamados(List<ChamadoModel> chamados) async {
    final db = await database;
    final batch = db.batch();
    for (final c in chamados) {
      batch.insert(
        AppConstants.tableChamados,
        c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retorna todos os chamados com status 'aberto' — RF06
  Future<List<ChamadoModel>> getChamadosAbertos() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableChamados,
      where: 'status = ?',
      whereArgs: [AppConstants.statusAberto],
    );
    return maps.map((m) => ChamadoModel.fromMap(m)).toList();
  }

  /// Busca chamado pelo id
  Future<ChamadoModel?> getChamadoById(int id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableChamados,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ChamadoModel.fromMap(maps.first);
  }

  /// Atualiza status do chamado — RF12
  Future<void> updateChamadoStatus(int id, String status) async {
    final db = await database;
    await db.update(
      AppConstants.tableChamados,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── ATENDIMENTOS ────────────────────────────────────────────────────────────

  /// Grava atendimento localmente com sincronizado = 0 — RF12
  Future<int> insertAtendimento(AtendimentoModel atendimento) async {
    final db = await database;
    return db.insert(
      AppConstants.tableAtendimentos,
      atendimento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retorna todos os atendimentos — RF14
  Future<List<AtendimentoModel>> getAllAtendimentos() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableAtendimentos,
      orderBy: 'id DESC',
    );
    return maps.map((m) => AtendimentoModel.fromMap(m)).toList();
  }

  /// Retorna atendimentos pendentes de sincronização — RF13
  Future<List<AtendimentoModel>> getAtendimentosPendentes() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableAtendimentos,
      where: 'sincronizado = ?',
      whereArgs: [AppConstants.sincronizadoPendente],
    );
    return maps.map((m) => AtendimentoModel.fromMap(m)).toList();
  }

  /// Marca atendimento como sincronizado, guardando a URL remota da foto — RF13
  Future<void> markAtendimentoSincronizado(int id, {String? fotoUrl}) async {
    final db = await database;
    await db.update(
      AppConstants.tableAtendimentos,
      {
        'sincronizado': AppConstants.sincronizadoOk,
        if (fotoUrl != null) 'foto_url': fotoUrl,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fecha o banco (útil em testes)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
