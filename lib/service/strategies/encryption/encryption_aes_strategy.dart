import 'dart:typed_data';

import 'package:crypton/exception/invalid_password_exception.dart';
import 'package:crypton/model/task_settings.dart' as TS;
import 'package:crypton/service/strategies/encryption/encryption_strategy.dart';
import 'package:encrypt/encrypt.dart' as ENCRYPT;

class EncryptionAesStrategy extends EncryptionStrategy {
  @override
  TS.Algorithm getStrategyName() {
    return TS.Algorithm.aes;
  }

  @override
  Future<Uint8List> encryptData(final TS.Algorithm algorithm,
      final Uint8List data, final String password) async {
    try {
      final ENCRYPT.Key key = ENCRYPT.Key.fromUtf8(password);

      const int ivLength = 16;

      final iv = ENCRYPT.IV.fromLength(ivLength);

      final ENCRYPT.Encrypter encrypter = ENCRYPT.Encrypter(ENCRYPT.AES(key));

      final encrypted = encrypter.encryptBytes(data, iv: iv);

      return encrypted.bytes;
    } catch (exception) {
      throw InvalidPasswordException("Wrong algorithm/password");
    }
  }
}
