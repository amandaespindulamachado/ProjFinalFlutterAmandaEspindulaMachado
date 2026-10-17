import 'package:flutter_test/flutter_test.dart';
import 'package:isp_tech_app/data/models/atendimento_model.dart';
import 'package:isp_tech_app/data/repositories/atendimento_repository.dart';

void main() {
  group('AtendimentoRepository.filtrar (RF15)', () {
    late AtendimentoRepository repo;

    final lista = <AtendimentoModel>[
      const AtendimentoModel(
        id: 1,
        chamadoId: 10,
        codigoCliente: 'CLI001',
        categoriaTecnica: 'Fibra',
        descricaoProcedimento: 'Procedimento A feito com sucesso.',
        dataConclusao: '2026-10-15',
        sincronizado: 1,
      ),
      const AtendimentoModel(
        id: 2,
        chamadoId: 25,
        codigoCliente: 'CLI002',
        categoriaTecnica: 'Wireless',
        descricaoProcedimento: 'Substitui o roteador do cliente.',
        dataConclusao: '2026-10-16',
        sincronizado: 0,
      ),
      const AtendimentoModel(
        id: 3,
        chamadoId: 100,
        codigoCliente: 'CLI100',
        categoriaTecnica: 'Roteador',
        descricaoProcedimento: 'Configuração realizada.',
        dataConclusao: '2026-10-16',
        sincronizado: 1,
      ),
    ];

    setUp(() {
      repo = AtendimentoRepository();
    });

    test('query vazia deve retornar lista completa', () {
      final result = repo.filtrar(lista, '');
      expect(result.length, 3);
    });

    test('filtrar por ID do chamado "25" deve retornar 1 item', () {
      final result = repo.filtrar(lista, '25');
      expect(result.length, 1);
      expect(result.first.chamadoId, 25);
    });

    test('filtrar por código do cliente "CLI002" deve retornar 1 item', () {
      final result = repo.filtrar(lista, 'CLI002');
      expect(result.length, 1);
      expect(result.first.codigoCliente, 'CLI002');
    });

    test('filtrar por termo inexistente deve retornar lista vazia', () {
      final result = repo.filtrar(lista, 'XYZ999');
      expect(result, isEmpty);
    });

    test('filtrar por "cli" (case-insensitive) deve retornar todos', () {
      final result = repo.filtrar(lista, 'cli');
      expect(result.length, 3);
    });

    test('filtrar por "10" deve retornar 2 (chamadoId 10 e 100 contêm "10")',
        () {
      final result = repo.filtrar(lista, '10');
      // chamadoId 10 contém "10", chamadoId 100 contém "10"
      expect(result.length, 2);
      expect(result.any((a) => a.chamadoId == 10), isTrue);
      expect(result.any((a) => a.chamadoId == 100), isTrue);
    });
  });
}
