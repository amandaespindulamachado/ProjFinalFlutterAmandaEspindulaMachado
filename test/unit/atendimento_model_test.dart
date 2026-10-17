import 'package:flutter_test/flutter_test.dart';
import 'package:isp_tech_app/data/models/atendimento_model.dart';

void main() {
  group('AtendimentoModel', () {
    final map = <String, dynamic>{
      'id': 5,
      'chamado_id': 10,
      'codigo_cliente': 'CLI002',
      'categoria_tecnica': 'Roteador',
      'descricao_procedimento': 'Substituí o roteador danificado e reconfigurou a rede.',
      'data_conclusao': '2026-10-16',
      'foto_caminho': '/data/user/0/app/fotos/os_123.jpg',
      'foto_url': null,
      'sincronizado': 0,
    };

    test('fromMap deve criar instância correta', () {
      final model = AtendimentoModel.fromMap(map);

      expect(model.id, 5);
      expect(model.chamadoId, 10);
      expect(model.codigoCliente, 'CLI002');
      expect(model.categoriaTecnica, 'Roteador');
      expect(model.descricaoProcedimento,
          'Substituí o roteador danificado e reconfigurou a rede.');
      expect(model.dataConclusao, '2026-10-16');
      expect(model.fotoCaminho, '/data/user/0/app/fotos/os_123.jpg');
      expect(model.sincronizado, 0);
    });

    test('toMap deve serializar corretamente', () {
      final model = AtendimentoModel.fromMap(map);
      final m = model.toMap();

      expect(m['id'], 5);
      expect(m['chamado_id'], 10);
      expect(m['sincronizado'], 0);
      expect(m['foto_caminho'], '/data/user/0/app/fotos/os_123.jpg');
    });

    test('isPendente deve retornar true quando sincronizado == 0', () {
      final model = AtendimentoModel.fromMap(map);
      expect(model.isPendente, isTrue);
    });

    test('isPendente deve retornar false quando sincronizado == 1', () {
      final m = Map<String, dynamic>.from(map);
      m['sincronizado'] = 1;
      final model = AtendimentoModel.fromMap(m);
      expect(model.isPendente, isFalse);
    });

    test('copyWith deve atualizar sincronizado e fotoUrl', () {
      final model = AtendimentoModel.fromMap(map);
      final atualizado = model.copyWith(
        sincronizado: 1,
        fotoUrl: 'https://exemplo.com/foto.jpg',
      );

      expect(atualizado.sincronizado, 1);
      expect(atualizado.fotoUrl, 'https://exemplo.com/foto.jpg');
      // Campos não alterados preservados
      expect(atualizado.chamadoId, model.chamadoId);
      expect(atualizado.descricaoProcedimento, model.descricaoProcedimento);
    });

    test('fromJson deve marcar sincronizado = 1 automaticamente', () {
      final json = {
        'id': 1,
        'chamado_id': 7,
        'codigo_cliente': 'CLI003',
        'categoria_tecnica': 'Fibra Óptica',
        'descricao_procedimento': 'Teste remoto.',
        'data_conclusao': '2026-10-16',
        'foto_url': 'https://cdn.exemplo.com/7.jpg',
      };
      final model = AtendimentoModel.fromJson(json);
      expect(model.sincronizado, 1);
      expect(model.fotoUrl, 'https://cdn.exemplo.com/7.jpg');
    });
  });
}
