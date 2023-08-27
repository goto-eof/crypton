import 'dart:typed_data';

import 'package:crypton/model/task_settings.dart';
import 'package:crypton/service/strategies/strategy_common.dart';

abstract class EncryptionStrategy extends StrategyCommon {
  Future<Uint8List> encryptData(
      final Algorithm algorithm, final Uint8List data, final String password);
}
