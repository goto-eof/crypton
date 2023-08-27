import 'dart:typed_data';

import 'package:crypton/model/task_settings.dart';
import 'package:crypton/service/file_util.dart';
import 'package:crypton/service/strategies/decryption/decryption_aes_strategy.dart';
import 'package:crypton/service/strategies/decryption/decryption_fernet_strategy.dart';
import 'package:crypton/service/strategies/decryption/decryption_salsa_strategy.dart';
import 'package:crypton/service/strategies/decryption/decryption_strategy.dart';

final List<DecryptionStrategy> encryptionStrategies = [
  DecryptionAesStrategy(),
  DecryptionFernetStrategy(),
  DecryptionSalsaStrategy()
];

class FileDecryptionService {
  Future<void> decryptFile(final String filePathAndName,
      final Algorithm algorithm, final String password) async {
    Uint8List bytesToEncrypt = await FileUtil.readFile(filePathAndName);

    Uint8List encryptedData = await retrieveStrategy(algorithm)
        .decryptData(algorithm, bytesToEncrypt, password);

    final String fileToSavePathAndName =
        FileUtil.removeLastFileNameExtension(filePathAndName);

    await FileUtil.writeOnFile(fileToSavePathAndName, encryptedData);
  }

  DecryptionStrategy retrieveStrategy(final Algorithm algorithm) {
    return encryptionStrategies
        .firstWhere((element) => element.getStrategyName() == algorithm);
  }
}
