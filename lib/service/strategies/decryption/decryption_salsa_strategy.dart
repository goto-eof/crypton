import 'dart:convert';
import 'dart:typed_data';

import 'package:crypton/exception/invalid_password_exception.dart';
import 'package:crypton/model/task_settings.dart' as TS;
import 'package:crypton/service/strategies/decryption/decryption_strategy.dart';
import 'package:encrypt/encrypt.dart' as ENCRYPT;

class DecryptionSalsaStrategy extends DecryptionStrategy {
  @override
  TS.Algorithm getStrategyName() {
    return TS.Algorithm.salsa;
  }

  @override
  Future<Uint8List> decryptData(final TS.Algorithm algorithm,
      final Uint8List data, final String password) async {
    try {
      final ENCRYPT.Key key = ENCRYPT.Key.fromUtf8(password);
      const int ivLength = 8;
      final iv = ENCRYPT.IV.fromLength(ivLength);
      final ENCRYPT.Encrypter encrypter =
          ENCRYPT.Encrypter(ENCRYPT.Salsa20(key));
      final dataToDecrypt = base64.encode(data);
      final List<int> decrypted = encrypter
          .decryptBytes(ENCRYPT.Encrypted.fromBase64(dataToDecrypt), iv: iv);

      return Uint8List.fromList(decrypted);
    } catch (exception) {
      throw InvalidPasswordException("Wrong algorithm/password");
    }
  }
}
