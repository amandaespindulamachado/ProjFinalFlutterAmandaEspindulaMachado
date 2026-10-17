import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/chamado_model.dart';
import '../../models/atendimento_model.dart';
import '../../../core/constants/app_constants.dart';

/// Exceção de API com código HTTP e mensagem.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Datasource remoto — comunicação com a API REST — RF03, RF04, RF13
class ApiDatasource {
  const ApiDatasource({http.Client? client}) : _client = client;
  final http.Client? _client;

  http.Client get _http => _client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${AppConstants.baseUrl}$path');

  // ── Autenticação ──────────────────────────────────────────────────────────

  /// Autentica técnico e retorna token Bearer — RF03
  Future<String> login({
    required String email,
    required String senhaHash,
  }) async {
    final response = await _http.post(
      _uri(AppConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senhaHash}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final token = body['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const ApiException(200, 'Token não encontrado na resposta.');
      }
      return token;
    }

    throw ApiException(response.statusCode, _extractMessage(response.body));
  }

  // ── Chamados ──────────────────────────────────────────────────────────────

  /// Busca lista de chamados do técnico autenticado — RF04
  Future<List<ChamadoModel>> fetchChamados(String token) async {
    final response = await _http.get(
      _uri(AppConstants.chamadosEndpoint),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> list = body is List ? body : (body['data'] ?? []);
      return list
          .map((j) => ChamadoModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(response.statusCode, _extractMessage(response.body));
  }

  // ── Atendimentos ──────────────────────────────────────────────────────────

  /// Envia atendimento com foto via multipart/form-data — RF13
  Future<AtendimentoModel> uploadAtendimento(
    String token,
    AtendimentoModel atendimento,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      _uri(AppConstants.atendimentoEndpoint),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Campos de texto
    request.fields['chamado_id'] = atendimento.chamadoId.toString();
    request.fields['codigo_cliente'] = atendimento.codigoCliente;
    request.fields['categoria_tecnica'] = atendimento.categoriaTecnica;
    request.fields['descricao_procedimento'] =
        atendimento.descricaoProcedimento;
    request.fields['data_conclusao'] = atendimento.dataConclusao;

    // Arquivo de foto (obrigatório para POST)
    if (atendimento.fotoCaminho != null) {
      final file = File(atendimento.fotoCaminho!);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', atendimento.fotoCaminho!),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return AtendimentoModel.fromJson(body);
    }

    throw ApiException(response.statusCode, _extractMessage(response.body));
  }

  /// Busca histórico de atendimentos da API — RF14
  Future<List<AtendimentoModel>> fetchHistorico(String token) async {
    final response = await _http.get(
      _uri(AppConstants.historicoEndpoint),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> list = body is List ? body : (body['data'] ?? []);
      return list
          .map((j) => AtendimentoModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(response.statusCode, _extractMessage(response.body));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  String _extractMessage(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return map['message'] as String? ??
          map['error'] as String? ??
          body;
    } catch (_) {
      return body;
    }
  }
}
