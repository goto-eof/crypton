import 'package:crypton/model/file_metadata.dart';

enum Action { encrypt, decrypt }

enum Target { singleFile, directory }

enum Algorithm { aes, fernet, salsa }

class TaskSettings {
  TaskSettings(
      {required this.action,
      required this.files,
      required this.algorithm,
      required this.password,
      required this.isDeleteOriginalFilesOnCompletion});
  final Action action;
  List<FileMetadata> files;
  final Algorithm algorithm;
  final String password;
  final bool isDeleteOriginalFilesOnCompletion;
}
