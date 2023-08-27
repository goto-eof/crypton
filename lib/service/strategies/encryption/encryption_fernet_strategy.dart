import 'dart:convert';
import 'dart:typed_data';

import 'package:crypton/exception/invalid_password_exception.dart';
import 'package:crypton/model/task_settings.dart' as TS;
import 'package:crypton/service/strategies/encryption/encryption_strategy.dart';
import 'package:encrypt/encrypt.dart' as ENCRYPT;

class EncryptionFernetStrategy extends EncryptionStrategy {
  @override
  TS.Algorithm getStrategyName() {
    return TS.Algorithm.fernet;
  }

  @override
  Future<Uint8List> encryptData(final TS.Algorithm algorithm,
      final Uint8List data, final String password) async {
    try {
      final ENCRYPT.Key key;
      final key1 = ENCRYPT.Key.fromUtf8(password);
      key = ENCRYPT.Key.fromUtf8(base64Url.encode(key1.bytes));

      const int ivLength = 16;

      final iv = ENCRYPT.IV.fromLength(ivLength);

      final ENCRYPT.Encrypter encrypter =
          ENCRYPT.Encrypter(ENCRYPT.Fernet(key));

      final encrypted = encrypter.encryptBytes(data, iv: iv);

      return encrypted.bytes;
    } catch (exception) {
      throw InvalidPasswordException("Wrong algorithm/password");
    }
  }
}
