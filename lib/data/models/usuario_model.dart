/// Modelo de usuário (técnico) retornado pela API após login.
class UsuarioModel {
  final int id;
  final String nome;
  final String email;
  final String token;

  const UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.token,
  });

  /// Cria instância a partir do JSON da API.
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  /// Serializa para JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'token': token,
      };

  @override
  String toString() => 'UsuarioModel(id: $id, nome: $nome, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
