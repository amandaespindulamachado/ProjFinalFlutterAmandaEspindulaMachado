import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:isp_tech_app/data/datasources/remote/api_datasource.dart';

void main() {
  group('ApiDatasource', () {
    test('login deve retornar token quando statusCode 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'token': 'meu_token_jwt_123'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final ds = ApiDatasource(client: mockClient);
      final token = await ds.login(email: 'teste@senai.br', senhaHash: 'abc123');

      expect(token, 'meu_token_jwt_123');
    });

    test('login deve lançar ApiException em credenciais inválidas (401)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Credenciais inválidas'}),
          401,
        );
      });

      final ds = ApiDatasource(client: mockClient);

      expect(
        () => ds.login(email: 'errado@senai.br', senhaHash: 'hash_errado'),
        throwsA(isA<ApiException>()),
      );
    });

    test('login deve lançar ApiException quando token ausente na resposta', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'outro_campo': 'qualquer'}),
          200,
        );
      });

      final ds = ApiDatasource(client: mockClient);

      expect(
        () => ds.login(email: 'a@b.com', senhaHash: 'xyz'),
        throwsA(isA<ApiException>()),
      );
    });

    test('fetchChamados deve retornar lista de ChamadoModel', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/chamados'));
        expect(request.headers['Authorization'], 'Bearer tk123');
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'codigo_cliente': 'CLI001',
              'nome_cliente': 'João',
              'categoria': 'Fibra',
              'resumo_problema': 'Sem sinal',
              'endereco': 'Rua A',
              'cidade': 'Floripa',
              'estado': 'SC',
              'latitude': -27.5,
              'longitude': -48.5,
              'status': 'aberto',
              'data_criacao': '2026-10-15',
            },
            {
              'id': 2,
              'codigo_cliente': 'CLI002',
              'nome_cliente': 'Maria',
              'categoria': 'Wireless',
              'resumo_problema': 'Lentidão',
              'endereco': 'Rua B',
              'cidade': 'Floripa',
              'estado': 'SC',
              'latitude': -27.6,
              'longitude': -48.6,
              'status': 'aberto',
              'data_criacao': '2026-10-16',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final ds = ApiDatasource(client: mockClient);
      final lista = await ds.fetchChamados('tk123');

      expect(lista.length, 2);
      expect(lista[0].id, 1);
      expect(lista[0].nomeCliente, 'João');
      expect(lista[1].codigoCliente, 'CLI002');
    });

    test('fetchChamados deve lançar ApiException em erro 500', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Erro interno do servidor'}),
          500,
        );
      });

      final ds = ApiDatasource(client: mockClient);

      expect(
        () => ds.fetchChamados('tk'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
