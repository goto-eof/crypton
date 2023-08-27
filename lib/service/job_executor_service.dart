import 'package:crypton/exception/file_already_encrypted_exception.dart';
import 'package:crypton/exception/invalid_password_exception.dart';
import 'package:crypton/model/file_metadata.dart';
import 'package:crypton/model/task_settings.dart' as TS;
import 'package:crypton/service/file_decryption_service.dart';
import 'package:crypton/service/file_encryption_service.dart';
import 'package:crypton/service/file_util.dart';

class JobExecutorService {
  FileEncryptionService fileEncryptionService = FileEncryptionService();
  FileDecryptionService fileDecryptionService = FileDecryptionService();

  Future<void> executeTaskEncryption(TS.TaskSettings taskSettings) async {
    for (FileMetadata platformFile in taskSettings.files) {
      await _executeTask(
          platformFile,
          taskSettings.action,
          taskSettings.algorithm,
          taskSettings.password,
          taskSettings.isDeleteOriginalFilesOnCompletion);
    }
  }

  Future<void> _executeTask(
      FileMetadata fileMetadata,
      TS.Action action,
      TS.Algorithm algorithm,
      String password,
      bool isDeleteOriginalFiles) async {
    if (TS.Action.encrypt == action) {
      return await encryptFileAndDeleteIfNecessary(
          fileMetadata, algorithm, password, isDeleteOriginalFiles);
    }
    return await decryptFileAndDeleteIfNecessary(
        fileMetadata, algorithm, password, isDeleteOriginalFiles);
  }

  Future<void> decryptFileAndDeleteIfNecessary(
      FileMetadata fileMetadata,
      TS.Algorithm algorithm,
      String password,
      final bool isDeleteOriginalFiles) async {
    try {
      await fileDecryptionService.decryptFile(
          fileMetadata.platformFile.path!, algorithm, password);
      await deleteOriginalFileIfNecessary(
          isDeleteOriginalFiles, fileMetadata.platformFile.path!);
    } on InvalidPasswordException catch (_) {
      fileMetadata.message = "Invalid algorithm or password?";
      fileMetadata.messageType = MessageType.error;
    }
  }

  Future<void> deleteOriginalFileIfNecessary(
      bool isDeleteOriginalFiles, String filePathAndName) async {
    if (isDeleteOriginalFiles) {
      await FileUtil.deleteFile(filePathAndName);
    }
  }

  Future<void> encryptFileAndDeleteIfNecessary(
      FileMetadata fileMetadata,
      TS.Algorithm algorithm,
      String password,
      final bool isDeleteOriginalFiles) async {
    try {
      await fileEncryptionService.encryptFile(
          fileMetadata.platformFile.path!, algorithm, password);
      await deleteOriginalFileIfNecessary(
          isDeleteOriginalFiles, fileMetadata.platformFile.path!);
    } on InvalidPasswordException catch (_) {
      fileMetadata.message = "Invalid password or algorithm?";
      fileMetadata.messageType = MessageType.error;
    } on FileAlreadyEncryptedException catch (_) {
      fileMetadata.message =
          "File already encrypted with the same algorithm. Skipped.";
      fileMetadata.messageType = MessageType.warning;
    }
  }
}
