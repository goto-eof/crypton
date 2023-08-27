import 'dart:typed_data';

import 'package:crypton/model/task_settings.dart';
import 'package:crypton/service/file_util.dart';
import 'package:crypton/service/strategies/encryption/encryption_aes_strategy.dart';
import 'package:crypton/service/strategies/encryption/encryption_fernet_strategy.dart';
import 'package:crypton/service/strategies/encryption/encryption_salsa_strategy.dart';
import 'package:crypton/service/strategies/encryption/encryption_strategy.dart';
import 'package:crypton/service/strategies/encryption/encryption_util.dart';
import 'package:crypton/service/strategies/strategies_util.dart';

final List<EncryptionStrategy> encryptionStrategies = [
  EncryptionAesStrategy(),
  EncryptionFernetStrategy(),
  EncryptionSalsaStrategy()
];

class FileEncryptionService {
  Future<void> encryptFile(final String filePathAndName,
      final Algorithm algorithm, final String password) async {
    EncryptionUtil.validateFileName(filePathAndName, algorithm);

    Uint8List bytesToEncrypt = await FileUtil.readFile(filePathAndName);

    Uint8List encryptedData = await retrieveStrategy(algorithm)
        .encryptData(algorithm, bytesToEncrypt, password);
    final String fileToSavePathAndName =
        "$filePathAndName.${StrategiesUtils.calculateFileExtension(algorithm)}";
    await FileUtil.writeOnFile(fileToSavePathAndName, encryptedData);
  }

  EncryptionStrategy retrieveStrategy(final Algorithm algorithm) {
    return encryptionStrategies
        .firstWhere((element) => element.getStrategyName() == algorithm);
  }
}
