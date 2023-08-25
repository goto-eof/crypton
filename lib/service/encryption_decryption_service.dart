import 'dart:convert';
import 'dart:io';

import 'package:crypton/model/file_metadata.dart';
import 'package:crypton/model/task_settings.dart' as TS;
import 'package:encrypt/encrypt.dart' as ENCRYPT;

class EncryptionDecryptionService {
  static Future<void> executeTaskEncryption(
      TS.TaskSettings taskSettings) async {
    for (FileMetadata platformFile in taskSettings.files) {
      await _executeTask(platformFile, taskSettings.action,
          taskSettings.algorithm, taskSettings.password);
    }
  }

  static Future<void> _executeTask(FileMetadata fileMetadata, TS.Action action,
      TS.Algorithm algorithm, String password) async {
    if (TS.Action.encrypt == action) {
      try {
        await _encryptFile(fileMetadata, algorithm, password);
      } catch (_) {
        fileMetadata.errorMessage = "[ERR][Invalid password or algorithm?]";
      }
    } else if (TS.Action.decrypt == action) {
      try {
        await _decryptFile(fileMetadata, algorithm, password);
      } catch (_) {
        fileMetadata.errorMessage = "[ERR][Invalid password or algorithm?]";
      }
    }
  }

  static Future<void> _encryptFile(
      FileMetadata file, TS.Algorithm algorithm, String password) async {
    try {
      File inFile = File(file.platformFile.path!);
      File outFile = File(
          "${file.platformFile.path!}.${calculateFileExtension(algorithm)}");

      final dataToEncrypt = await inFile.readAsBytes();

      final ENCRYPT.Key key;
      if (TS.Algorithm.fernet == algorithm) {
        final key1 = ENCRYPT.Key.fromUtf8(password);
        key = ENCRYPT.Key.fromUtf8(base64Url.encode(key1.bytes));
      } else if (TS.Algorithm.aes == algorithm ||
          TS.Algorithm.salsa == algorithm) {
        key = ENCRYPT.Key.fromUtf8(password);
      } else {
        throw Exception("Invalid algorithm 1");
      }

      final ivLength;
      if (TS.Algorithm.aes == algorithm) {
        ivLength = 16;
      } else if (TS.Algorithm.fernet == algorithm) {
        ivLength = 16;
      } else if (TS.Algorithm.salsa == algorithm) {
        ivLength = 8;
      } else {
        throw Exception("Invalid algorithm 2");
      }

      final iv = ENCRYPT.IV.fromLength(ivLength);
      final encrypter;
      if (TS.Algorithm.aes == algorithm) {
        encrypter = ENCRYPT.Encrypter(ENCRYPT.AES(key));
      } else if (TS.Algorithm.fernet == algorithm) {
        encrypter = ENCRYPT.Encrypter(ENCRYPT.Fernet(key));
      } else if (TS.Algorithm.salsa == algorithm) {
        encrypter = ENCRYPT.Encrypter(ENCRYPT.Salsa20(key));
      } else {
        throw Exception("Invalid algorithm 2");
      }
      final encrypted = encrypter.encryptBytes(dataToEncrypt, iv: iv);
      await outFile.writeAsBytes(encrypted.bytes);
    } catch (exception) {
      throw Exception("Task failed");
    }
  }

  static Future<void> _decryptFile(
      FileMetadata file, TS.Algorithm algorithm, String password) async {
    File inFile = File(file.platformFile.path!);
    RegExp regExp = RegExp(r'.*(?=\.)');
    File outFile = File(regExp.firstMatch(file.platformFile.path!)![0]!);

    final ENCRYPT.Key key;
    if (TS.Algorithm.fernet == algorithm) {
      final key1 = ENCRYPT.Key.fromUtf8(password);
      key = ENCRYPT.Key.fromUtf8(base64Url.encode(key1.bytes));
    } else if (TS.Algorithm.aes == algorithm ||
        TS.Algorithm.salsa == algorithm) {
      key = ENCRYPT.Key.fromUtf8(password);
    } else {
      throw Exception("Invalid algorithm 6");
    }
    final ivLength;
    if (TS.Algorithm.aes == algorithm) {
      ivLength = 16;
    } else if (TS.Algorithm.fernet == algorithm) {
      ivLength = 16;
    } else if (TS.Algorithm.salsa == algorithm) {
      ivLength = 8;
    } else {
      throw Exception("Invalid algorithm 2");
    }
    final iv = ENCRYPT.IV.fromLength(ivLength);
    final encrypter;
    if (TS.Algorithm.aes == algorithm) {
      encrypter = ENCRYPT.Encrypter(ENCRYPT.AES(key));
    } else if (TS.Algorithm.fernet == algorithm) {
      encrypter = ENCRYPT.Encrypter(ENCRYPT.Fernet(key));
    } else if (TS.Algorithm.salsa == algorithm) {
      encrypter = ENCRYPT.Encrypter(ENCRYPT.Salsa20(key));
    } else {
      throw Exception("Invalid algorithm 5");
    }
    final dataToDecrypt = base64.encode(await inFile.readAsBytes());
    final decrypted;
    if (TS.Algorithm.fernet == algorithm) {
      decrypted =
          encrypter.decryptBytes(ENCRYPT.Encrypted.fromBase64(dataToDecrypt));
    } else if (TS.Algorithm.aes == algorithm ||
        TS.Algorithm.salsa == algorithm) {
      decrypted = encrypter
          .decryptBytes(ENCRYPT.Encrypted.fromBase64(dataToDecrypt), iv: iv);
    } else {
      throw Exception("Invalid algorithm 4");
    }
    await outFile.writeAsBytes(decrypted);
  }

  static calculateFileExtension(algorithm) {
    if (TS.Algorithm.aes == algorithm) {
      return "aes";
    } else if (TS.Algorithm.fernet == algorithm) {
      return "fernet";
    } else if (TS.Algorithm.salsa == algorithm) {
      return "salsa";
    }
    throw Exception("Invalid algorithm 3");
  }
}
