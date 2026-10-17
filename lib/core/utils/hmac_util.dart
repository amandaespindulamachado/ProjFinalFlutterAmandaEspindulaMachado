import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../constants/app_constants.dart';

/// Utilitário para criptografia HMAC-SHA256
class HmacUtil {
  HmacUtil._();

  /// Assina [message] com a chave secreta compartilhada da turma.
  /// Retorna o hash em hexadecimal minúsculo.
  static String sign(String message) {
    final key = utf8.encode(AppConstants.hmacSecret);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
}
