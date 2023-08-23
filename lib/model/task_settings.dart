import 'package:file_picker/file_picker.dart';

enum Action { encrypt, decrypt }

enum Target { singleFile, directory }

enum Algorithm { aes, fernet, salsa }

class TaskSettings {
  TaskSettings(
      {required this.action,
      required this.files,
      required this.algorithm,
      required this.password});
  final Action action;
  final List<PlatformFile> files;
  final Algorithm algorithm;
  final String password;
}
