import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_tech_app/data/models/atendimento_model.dart';
import 'package:isp_tech_app/views/screens/detalhe_atendimento_screen.dart';

void main() {
  group('DetalheAtendimentoScreen (widget test)', () {
    final atendimentoPendente = const AtendimentoModel(
      id: 1,
      chamadoId: 10,
      codigoCliente: 'CLI001',
      categoriaTecnica: 'Roteador',
      descricaoProcedimento: 'Substituí o roteador e reconfigurei a rede WiFi.',
      dataConclusao: '2026-10-16',
      fotoCaminho: null,
      fotoUrl: null,
      sincronizado: 0,
    );

    final atendimentoSincronizado = const AtendimentoModel(
      id: 2,
      chamadoId: 25,
      codigoCliente: 'CLI002',
      categoriaTecnica: 'Fibra Óptica',
      descricaoProcedimento: 'Realizada fusão de cabo óptico no poste.',
      dataConclusao: '2026-10-15',
      fotoCaminho: null,
      fotoUrl: 'https://cdn.exemplo.com/foto.jpg',
      sincronizado: 1,
    );

    // Helper para injetar arguments via Navigator com route settings.
    Future<void> pumpDetalhe(
      WidgetTester tester,
      AtendimentoModel atendimento,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DetalheAtendimentoScreen(),
                    settings: RouteSettings(arguments: atendimento),
                  ),
                ),
                child: const Text('Abrir Detalhe'),
              ),
            ),
          ),
        ),
      );

      // Navega para a tela de detalhe
      await tester.tap(find.text('Abrir Detalhe'));
      await tester.pumpAndSettle();
    }

    testWidgets('deve exibir dados do atendimento pendente', (tester) async {
      await pumpDetalhe(tester, atendimentoPendente);

      expect(find.text('OS #10'), findsOneWidget);
      expect(find.text('CLI001'), findsOneWidget);
      expect(find.text('Roteador'), findsWidgets);
      expect(find.textContaining('Substituí o roteador'), findsOneWidget);
      expect(find.text('Pendente de Envio'), findsOneWidget);
    });

    testWidgets('deve exibir badge Sincronizado para atendimento enviado',
        (tester) async {
      await pumpDetalhe(tester, atendimentoSincronizado);

      expect(find.text('Sincronizado'), findsOneWidget);
      expect(find.textContaining('Sincronizado com sucesso'), findsOneWidget);
    });

    testWidgets('deve exibir seções Informações da OS, Parecer Técnico e Foto',
        (tester) async {
      await pumpDetalhe(tester, atendimentoPendente);

      expect(find.text('Informações da OS'), findsOneWidget);
      expect(find.text('Parecer Técnico'), findsOneWidget);
      expect(find.text('Foto do serviço'), findsOneWidget);
      expect(find.text('Status de envio'), findsOneWidget);
    });

    testWidgets('deve exibir texto "Sem foto registrada" quando não há foto',
        (tester) async {
      await pumpDetalhe(tester, atendimentoPendente);

      expect(find.text('Sem foto registrada'), findsOneWidget);
    });

    testWidgets('deve exibir data de conclusão', (tester) async {
      await pumpDetalhe(tester, atendimentoPendente);

      expect(find.text('2026-10-16'), findsWidgets);
    });
  });
}
