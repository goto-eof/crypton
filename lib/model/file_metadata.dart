import 'package:file_picker/file_picker.dart';

class FileMetadata {
  FileMetadata({required this.platformFile, this.errorMessage});

  final PlatformFile platformFile;
  String? errorMessage;
}
