/// Modelo de Atendimento (conclusão de OS) — RF01, RF09, RF12
class AtendimentoModel {
  final int? id; // null antes de inserir no SQLite
  final int chamadoId;
  final String codigoCliente;
  final String categoriaTecnica;
  final String descricaoProcedimento;
  final String dataConclusao;
  final String? fotoCaminho; // caminho absoluto no dispositivo
  final String? fotoUrl;     // URL remota após sincronização
  final int sincronizado;    // 0 = pendente, 1 = enviado

  const AtendimentoModel({
    this.id,
    required this.chamadoId,
    required this.codigoCliente,
    required this.categoriaTecnica,
    required this.descricaoProcedimento,
    required this.dataConclusao,
    this.fotoCaminho,
    this.fotoUrl,
    required this.sincronizado,
  });

  // ── API REST ─────────────────────────────────────────────────────────────────

  factory AtendimentoModel.fromJson(Map<String, dynamic> json) {
    return AtendimentoModel(
      id: json['id'] as int?,
      chamadoId: json['chamado_id'] as int? ?? 0,
      codigoCliente: json['codigo_cliente'] as String? ?? '',
      categoriaTecnica: json['categoria_tecnica'] as String? ?? '',
      descricaoProcedimento: json['descricao_procedimento'] as String? ?? '',
      dataConclusao: json['data_conclusao'] as String? ?? '',
      fotoCaminho: null,
      fotoUrl: json['foto_url'] as String?,
      sincronizado: 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chamado_id': chamadoId,
        'codigo_cliente': codigoCliente,
        'categoria_tecnica': categoriaTecnica,
        'descricao_procedimento': descricaoProcedimento,
        'data_conclusao': dataConclusao,
        'foto_url': fotoUrl,
        'sincronizado': sincronizado,
      };

  // ── SQLite ────────────────────────────────────────────────────────────────────

  factory AtendimentoModel.fromMap(Map<String, dynamic> map) {
    return AtendimentoModel(
      id: map['id'] as int?,
      chamadoId: map['chamado_id'] as int? ?? 0,
      codigoCliente: map['codigo_cliente'] as String? ?? '',
      categoriaTecnica: map['categoria_tecnica'] as String? ?? '',
      descricaoProcedimento: map['descricao_procedimento'] as String? ?? '',
      dataConclusao: map['data_conclusao'] as String? ?? '',
      fotoCaminho: map['foto_caminho'] as String?,
      fotoUrl: map['foto_url'] as String?,
      sincronizado: map['sincronizado'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'chamado_id': chamadoId,
        'codigo_cliente': codigoCliente,
        'categoria_tecnica': categoriaTecnica,
        'descricao_procedimento': descricaoProcedimento,
        'data_conclusao': dataConclusao,
        'foto_caminho': fotoCaminho,
        'foto_url': fotoUrl,
        'sincronizado': sincronizado,
      };

  // ── Helpers ───────────────────────────────────────────────────────────────────

  bool get isPendente => sincronizado == 0;

  AtendimentoModel copyWith({
    int? id,
    String? fotoUrl,
    int? sincronizado,
  }) {
    return AtendimentoModel(
      id: id ?? this.id,
      chamadoId: chamadoId,
      codigoCliente: codigoCliente,
      categoriaTecnica: categoriaTecnica,
      descricaoProcedimento: descricaoProcedimento,
      dataConclusao: dataConclusao,
      fotoCaminho: fotoCaminho,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }

  @override
  String toString() =>
      'AtendimentoModel(id: $id, chamadoId: $chamadoId, sincronizado: $sincronizado)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AtendimentoModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
