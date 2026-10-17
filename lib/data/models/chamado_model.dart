/// Modelo de Ordem de Serviço (chamado) — RF01
class ChamadoModel {
  final int id;
  final String codigoCliente;
  final String nomeCliente;
  final String categoria;
  final String resumoProblema;
  final String endereco;
  final String cidade;
  final String estado;
  final double latitude;
  final double longitude;
  final String status;
  final String dataCriacao;

  const ChamadoModel({
    required this.id,
    required this.codigoCliente,
    required this.nomeCliente,
    required this.categoria,
    required this.resumoProblema,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.dataCriacao,
  });

  // ── Comunicação com a API REST ──────────────────────────────────────────────

  factory ChamadoModel.fromJson(Map<String, dynamic> json) {
    return ChamadoModel(
      id: json['id'] as int? ?? 0,
      codigoCliente: json['codigo_cliente'] as String? ?? '',
      nomeCliente: json['nome_cliente'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      resumoProblema: json['resumo_problema'] as String? ?? '',
      endereco: json['endereco'] as String? ?? '',
      cidade: json['cidade'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      status: json['status'] as String? ?? 'aberto',
      dataCriacao: json['data_criacao'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'codigo_cliente': codigoCliente,
        'nome_cliente': nomeCliente,
        'categoria': categoria,
        'resumo_problema': resumoProblema,
        'endereco': endereco,
        'cidade': cidade,
        'estado': estado,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'data_criacao': dataCriacao,
      };

  // ── Persistência no SQLite ──────────────────────────────────────────────────

  factory ChamadoModel.fromMap(Map<String, dynamic> map) {
    return ChamadoModel(
      id: map['id'] as int? ?? 0,
      codigoCliente: map['codigo_cliente'] as String? ?? '',
      nomeCliente: map['nome_cliente'] as String? ?? '',
      categoria: map['categoria'] as String? ?? '',
      resumoProblema: map['resumo_problema'] as String? ?? '',
      endereco: map['endereco'] as String? ?? '',
      cidade: map['cidade'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      latitude: _parseDouble(map['latitude']),
      longitude: _parseDouble(map['longitude']),
      status: map['status'] as String? ?? 'aberto',
      dataCriacao: map['data_criacao'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'codigo_cliente': codigoCliente,
        'nome_cliente': nomeCliente,
        'categoria': categoria,
        'resumo_problema': resumoProblema,
        'endereco': endereco,
        'cidade': cidade,
        'estado': estado,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'data_criacao': dataCriacao,
      };

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Retorna endereço completo formatado.
  String get enderecoCompleto => '$endereco, $cidade - $estado';

  ChamadoModel copyWith({String? status}) {
    return ChamadoModel(
      id: id,
      codigoCliente: codigoCliente,
      nomeCliente: nomeCliente,
      categoria: categoria,
      resumoProblema: resumoProblema,
      endereco: endereco,
      cidade: cidade,
      estado: estado,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      dataCriacao: dataCriacao,
    );
  }

  @override
  String toString() =>
      'ChamadoModel(id: $id, cliente: $nomeCliente, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChamadoModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
