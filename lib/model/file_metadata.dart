import 'package:file_picker/file_picker.dart';

enum MessageType { warning, error, info }

class FileMetadata {
  FileMetadata({required this.platformFile, this.message, this.messageType});

  final PlatformFile platformFile;
  String? message;
  MessageType? messageType;
}
