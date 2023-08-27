import 'package:crypton/model/task_settings.dart';

class StrategiesUtils {
  static String calculateFileExtension(Algorithm algorithm) {
    return algorithm.name;
  }
}
