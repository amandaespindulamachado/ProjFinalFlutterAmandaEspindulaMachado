import 'package:flutter_test/flutter_test.dart';
import 'package:isp_tech_app/data/models/chamado_model.dart';

void main() {
  group('ChamadoModel', () {
    final jsonApi = {
      'id': 1,
      'codigo_cliente': 'CLI001',
      'nome_cliente': 'João Silva',
      'categoria': 'Fibra Óptica',
      'resumo_problema': 'Sem sinal na residência',
      'endereco': 'Rua das Flores, 123',
      'cidade': 'Florianópolis',
      'estado': 'SC',
      'latitude': -27.5945,
      'longitude': -48.5477,
      'status': 'aberto',
      'data_criacao': '2026-10-15',
    };

    test('fromJson deve criar instância com todos os campos', () {
      final model = ChamadoModel.fromJson(jsonApi);

      expect(model.id, 1);
      expect(model.codigoCliente, 'CLI001');
      expect(model.nomeCliente, 'João Silva');
      expect(model.categoria, 'Fibra Óptica');
      expect(model.resumoProblema, 'Sem sinal na residência');
      expect(model.endereco, 'Rua das Flores, 123');
      expect(model.cidade, 'Florianópolis');
      expect(model.estado, 'SC');
      expect(model.latitude, -27.5945);
      expect(model.longitude, -48.5477);
      expect(model.status, 'aberto');
      expect(model.dataCriacao, '2026-10-15');
    });

    test('toJson deve serializar corretamente', () {
      final model = ChamadoModel.fromJson(jsonApi);
      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['codigo_cliente'], 'CLI001');
      expect(json['nome_cliente'], 'João Silva');
      expect(json['latitude'], -27.5945);
    });

    test('fromMap deve criar instância a partir do mapa SQLite', () {
      final model = ChamadoModel.fromMap(jsonApi);
      expect(model.id, 1);
      expect(model.nomeCliente, 'João Silva');
    });

    test('toMap deve gerar mapa para o SQLite', () {
      final model = ChamadoModel.fromJson(jsonApi);
      final map = model.toMap();

      expect(map['id'], 1);
      expect(map['codigo_cliente'], 'CLI001');
      expect(map['latitude'], -27.5945);
    });

    test('enderecoCompleto deve formatar corretamente', () {
      final model = ChamadoModel.fromJson(jsonApi);
      expect(model.enderecoCompleto, 'Rua das Flores, 123, Florianópolis - SC');
    });

    test('copyWith deve manter demais campos ao alterar status', () {
      final model = ChamadoModel.fromJson(jsonApi);
      final atualizado = model.copyWith(status: 'atendido');

      expect(atualizado.status, 'atendido');
      expect(atualizado.id, model.id);
      expect(atualizado.nomeCliente, model.nomeCliente);
    });

    test('deve lidar com latitude como String (conversão)', () {
      final json = Map<String, dynamic>.from(jsonApi);
      json['latitude'] = '-27.5945';
      final model = ChamadoModel.fromJson(json);
      expect(model.latitude, -27.5945);
    });

    test('deve lidar com latitude como int', () {
      final json = Map<String, dynamic>.from(jsonApi);
      json['latitude'] = -27;
      final model = ChamadoModel.fromJson(json);
      expect(model.latitude, -27.0);
    });

    test('igualdade por id', () {
      final a = ChamadoModel.fromJson(jsonApi);
      final b = ChamadoModel.fromJson(jsonApi);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
