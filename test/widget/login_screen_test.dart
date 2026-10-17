import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_tech_app/viewmodels/auth_viewmodel.dart';
import 'package:isp_tech_app/views/screens/login_screen.dart';

void main() {
  group('LoginScreen (widget test)', () {
    late AuthViewModel viewModel;

    setUp(() {
      viewModel = AuthViewModel();
    });

    Future<void> pumpLogin(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(viewModel: viewModel)),
      );
    }

    testWidgets('deve exibir campos de email e senha e botão ENTRAR',
        (tester) async {
      await pumpLogin(tester);

      expect(find.text('E-mail institucional'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('ENTRAR'), findsOneWidget);
    });

    testWidgets('botão ENTRAR desabilita e mostra erro com email vazio',
        (tester) async {
      await pumpLogin(tester);

      // Toca ENTRAR sem preencher nada
      await tester.tap(find.text('ENTRAR'));
      await tester.pump();

      // Deve aparecer a mensagem de validação do email
      expect(find.text('Informe o e-mail'), findsOneWidget);
    });

    testWidgets('deve mostrar erro de email inválido sem @', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextFormField).first, 'emailsemarroba');
      await tester.enterText(find.byType(TextFormField).last, '123456');

      await tester.tap(find.text('ENTRAR'));
      await tester.pump();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve mostrar erro de senha curta', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextFormField).first, 'tech@senai.br');
      await tester.enterText(find.byType(TextFormField).last, '12');

      await tester.tap(find.text('ENTRAR'));
      await tester.pump();

      expect(find.text('Senha muito curta'), findsOneWidget);
    });

    testWidgets('deve alternar visibilidade da senha ao tocar no ícone',
        (tester) async {
      await pumpLogin(tester);

      // Busca o TextField interno do campo de senha (último TextFormField)
      final passwordWidget = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(TextField),
        ),
      );

      // Por padrão a senha está oculta
      expect(passwordWidget.obscureText, isTrue);

      // Toca no ícone de visibilidade
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      final passwordWidgetAlt = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordWidgetAlt.obscureText, isFalse);

      // Toca novamente para ocultar
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      final passwordWidgetAgain = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordWidgetAgain.obscureText, isTrue);
    });

    testWidgets('deve exibir texto de proteção HMAC-SHA256', (tester) async {
      await pumpLogin(tester);
      expect(find.text('Senha protegida com HMAC-SHA256'), findsOneWidget);
    });
  });
}
