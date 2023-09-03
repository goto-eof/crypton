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
      updateFileMetadataToDone(fileMetadata);
    } on InvalidPasswordException catch (_) {
      updateFileMetadataToError(fileMetadata);
    } catch (err) {
      updateFileMetadataToError(fileMetadata, errMessage: "Unknown error");
    }
  }

  void updateFileMetadataToError(FileMetadata fileMetadata,
      {String? errMessage}) {
    fileMetadata.message = "Invalid algorithm or password?";

    if (errMessage != null) {
      fileMetadata.message = errMessage;
    }
    fileMetadata.messageType = MessageType.error;
  }

  void updateFileMetadataToDone(FileMetadata fileMetadata) {
    fileMetadata.messageType = MessageType.info;
    fileMetadata.message = "done";
  }

  void updateFileMetadataToWarning(FileMetadata fileMetadata) {
    fileMetadata.message =
        "File already encrypted with the same algorithm. Skipped.";
    fileMetadata.messageType = MessageType.warning;
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
      updateFileMetadataToDone(fileMetadata);
    } on InvalidPasswordException catch (_) {
      updateFileMetadataToError(fileMetadata);
    } on FileAlreadyEncryptedException catch (_) {
      updateFileMetadataToWarning(fileMetadata);
    } catch (err) {
      updateFileMetadataToError(fileMetadata, errMessage: "Unknown error");
    }
  }
}
