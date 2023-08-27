import 'dart:io';
import 'dart:typed_data';

import 'package:crypton/model/task_settings.dart';

final RegExp regExp = RegExp(r'.*(?=\.)');

class FileUtil {
  static Future<Uint8List> readFile(String filePathAndName) async {
    File inFile = File(filePathAndName);
    return await inFile.readAsBytes();
  }

  static Future<void> writeOnFile(
      String filePathAndName, Uint8List bytes) async {
    File outFile = File(filePathAndName);
    await outFile.writeAsBytes(bytes);
  }

  static Future<void> deleteFile(String filePathAndName) async {
    File inFile = File(filePathAndName);
    await inFile.delete();
  }

  static String removeLastFileNameExtension(String filePathAndName) {
    return regExp.firstMatch(filePathAndName)![0]!;
  }

  static String calculateFileExtension(Algorithm algorithm) {
    return algorithm.name;
  }
}
