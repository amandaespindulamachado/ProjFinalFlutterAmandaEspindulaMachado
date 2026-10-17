import 'package:flutter_test/flutter_test.dart';
import 'package:isp_tech_app/core/utils/hmac_util.dart';

void main() {
  group('HmacUtil', () {
    test('sign deve retornar hash hexadecimal de 64 caracteres (SHA-256)', () {
      final hash = HmacUtil.sign('minhaSenha123');
      expect(hash.length, 64);
      // Deve conter apenas caracteres hexadecimais
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(hash), isTrue);
    });

    test('sign deve ser determinístico (mesma entrada, mesma saída)', () {
      final h1 = HmacUtil.sign('senhaTeste');
      final h2 = HmacUtil.sign('senhaTeste');
      expect(h1, equals(h2));
    });

    test('sign deve gerar hashes diferentes para senhas diferentes', () {
      final h1 = HmacUtil.sign('senhaA');
      final h2 = HmacUtil.sign('senhaB');
      expect(h1, isNot(equals(h2)));
    });

    test('sign deve gerar hash diferente do texto plano', () {
      final senha = '123456';
      final hash = HmacUtil.sign(senha);
      expect(hash, isNot(equals(senha)));
    });
  });
}
