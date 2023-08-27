import 'package:crypton/exception/file_already_encrypted_exception.dart';
import 'package:path/path.dart' as path;
import 'package:crypton/model/task_settings.dart';

class EncryptionUtil {
  static void validateFileName(
      final String filePathAndName, final Algorithm algorithm) {
    final String extension = path.extension(filePathAndName);
    if ('.${algorithm.name}' == extension) {
      throw FileAlreadyEncryptedException(
          "File already encrypted with the same algorithm. Skipped.");
    }
  }
}
