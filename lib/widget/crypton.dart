import 'dart:convert';
import 'dart:io';

import 'package:crypton/model/task_settings.dart' as TS;
import 'package:crypton/widget/form_new_task.dart';
import 'package:crypton/widget/task.dart';
import 'package:crypton/widget/task_metadata.dart';
import 'package:encrypt/encrypt.dart' as ENCRYPT;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Crypton extends StatefulWidget {
  const Crypton({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CryptonState();
  }
}

class _CryptonState extends State<Crypton> {
  int taskCounter = 0;
  List<TaskMetadata> tasks = [];

  void _showNewTaskForm() {
    showGeneralDialog(
        context: context,
        pageBuilder: _newTaskFormBuilder,
        barrierDismissible: false);
  }

  Widget _newTaskFormBuilder(BuildContext context, Animation<double> animation,
      Animation<double> animation2) {
    return FormNewTask(
      runNewTask: _addNewTask,
    );
  }

  void _addNewTask(TS.TaskSettings taskSettings) async {
    setState(() {
      tasks.add(
          TaskMetadata(taskSettings: taskSettings, status: TaskStatus.idle));
    });
  }

  Future<void> _executeTasks(TS.TaskSettings taskSettings) async {
    for (PlatformFile file in taskSettings.files) {
      await _executeTask(file, taskSettings.action, taskSettings.algorithm,
          taskSettings.password);
    }
  }

  Future<void> _executeTask(PlatformFile file, TS.Action action,
      TS.Algorithm algorithm, String password) async {
    if (TS.Action.encrypt == action) {
      await _encryptFile(file, algorithm, password);
    } else if (TS.Action.decrypt == action) {
      await _decryptFile(file, algorithm, password);
    }
  }

  Future<void> _encryptFile(file, algorithm, password) async {
    try {
      ScaffoldMessenger.of(context).clearMaterialBanners();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Encrypting file ${file.name} with $algorithm algorithm")));
      File inFile = File(file.path!);
      File outFile = File("${file.path!}.${calculateFileExtension(algorithm)}");

      final dataToEncrypt = await inFile.readAsBytes();

      final ENCRYPT.Key key;
      if (TS.Algorithm.fernet == algorithm) {
        final key1 = ENCRYPT.Key.fromUtf8(password);
        key = ENCRYPT.Key.fromUtf8(base64Url.encode(key1.bytes));
      } else if (TS.Algorithm.aes == algorithm ||
          TS.Algorithm.salsa == algorithm) {
        key = ENCRYPT.Key.fromUtf8(password);
      } else {
        throw Exception("Invalid algorithm 1");
      }

      final ivLength;
      if (TS.Algorithm.aes == algorithm) {
        ivLength = 16;
      } else if (TS.Algorithm.fernet == algorithm) {
        ivLength = 16;
      } else if (TS.Algorithm.salsa == algorithm) {
        ivLength = 8;
      } else {
        throw Exception("Invalid algorithm 2");
      }

      final iv = ENCRYPT.IV.fromLength(ivLength);
      final encrypter;
      if (TS.Algorithm.aes == algorithm) {
        encrypter = ENCRYPT.Encrypter(ENCRYPT.AES(key));
      } else if (TS.Algorithm.fernet == algorithm) {
        encrypter = ENCRYPT.Encrypter(ENCRYPT.Fernet(key));
      } else if (TS.Algorithm.salsa == algorithm) {
        encrypter = ENCRYPT.Encrypter(ENCRYPT.Salsa20(key));
      } else {
        throw Exception("Invalid algorithm 2");
      }
      final encrypted = encrypter.encryptBytes(dataToEncrypt, iv: iv);
      await outFile.writeAsBytes(encrypted.bytes);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).clearMaterialBanners();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Encryption finished with success.")));
    } catch (exception) {
      throw Exception("Task failed");
    }
  }

  Future<void> _decryptFile(
      PlatformFile file, TS.Algorithm algorithm, String password) async {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Decrypting file ${file.name} with $algorithm algorithm")));
    File inFile = File(file.path!);
    RegExp regExp = RegExp(r'.*(?=\.)');
    File outFile = File(regExp.firstMatch(file.path!)![0]!);

    final ENCRYPT.Key key;
    if (TS.Algorithm.fernet == algorithm) {
      final key1 = ENCRYPT.Key.fromUtf8(password);
      key = ENCRYPT.Key.fromUtf8(base64Url.encode(key1.bytes));
    } else if (TS.Algorithm.aes == algorithm ||
        TS.Algorithm.salsa == algorithm) {
      key = ENCRYPT.Key.fromUtf8(password);
    } else {
      throw Exception("Invalid algorithm 6");
    }
    final ivLength;
    if (TS.Algorithm.aes == algorithm) {
      ivLength = 16;
    } else if (TS.Algorithm.fernet == algorithm) {
      ivLength = 16;
    } else if (TS.Algorithm.salsa == algorithm) {
      ivLength = 8;
    } else {
      throw Exception("Invalid algorithm 2");
    }
    final iv = ENCRYPT.IV.fromLength(ivLength);
    final encrypter;
    if (TS.Algorithm.aes == algorithm) {
      encrypter = ENCRYPT.Encrypter(ENCRYPT.AES(key));
    } else if (TS.Algorithm.fernet == algorithm) {
      encrypter = ENCRYPT.Encrypter(ENCRYPT.Fernet(key));
    } else if (TS.Algorithm.salsa == algorithm) {
      encrypter = ENCRYPT.Encrypter(ENCRYPT.Salsa20(key));
    } else {
      throw Exception("Invalid algorithm 5");
    }
    final dataToDecrypt = base64.encode(await inFile.readAsBytes());
    final decrypted;
    if (TS.Algorithm.fernet == algorithm) {
      decrypted =
          encrypter.decryptBytes(ENCRYPT.Encrypted.fromBase64(dataToDecrypt));
    } else if (TS.Algorithm.aes == algorithm ||
        TS.Algorithm.salsa == algorithm) {
      decrypted = encrypter
          .decryptBytes(ENCRYPT.Encrypted.fromBase64(dataToDecrypt), iv: iv);
    } else {
      throw Exception("Invalid algorithm 4");
    }
    await outFile.writeAsBytes(decrypted);

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Decryption finished with success.")));
  }

  calculateFileExtension(algorithm) {
    if (TS.Algorithm.aes == algorithm) {
      return "aes";
    } else if (TS.Algorithm.fernet == algorithm) {
      return "fernet";
    } else if (TS.Algorithm.salsa == algorithm) {
      return "salsa";
    }
    throw Exception("Invalid algorithm 3");
  }

  Widget _aboutDialogBuilder(BuildContext context) {
    return AlertDialog(
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Ok",
            ),
          ),
        ],
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Developed by Andrei Dodu.",
            ),
            Text("Version: 0.1.0 (2023)"),
          ],
        ));
  }

  Widget _alertDialogBuilder(BuildContext context) {
    return AlertDialog(
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              for (TaskMetadata task in tasks) {
                setState(() {
                  task.status = TaskStatus.processing;
                });
                try {
                  await _executeTasks(task.taskSettings);
                } on Error catch (err) {
                  setState(() {
                    task.status = TaskStatus.error;
                  });
                  if (Navigator.of(context).mounted) {
                    Navigator.of(context).pop();
                  }
                  return;
                }
                setState(() {
                  task.status = TaskStatus.done;
                });
              }

              if (Navigator.of(context).mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              "Proceed",
            ),
          )
        ],
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure that you want to continue? ",
            ),
            Text("Remember that Crypton will override files."),
            Text(
                " Moreover the developer is not responsible for any data loss produced by the application.")
          ],
        ));
  }

  void _delete(TaskMetadata taskMetadata) {
    setState(() {
      tasks.remove(taskMetadata);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: _aboutDialogBuilder,
                );
              },
              icon: const Icon(Icons.info)),
          IconButton(
              onPressed: () {
                showDialog(context: context, builder: _alertDialogBuilder);
              },
              icon: const Icon(Icons.play_arrow)),
          IconButton(onPressed: _showNewTaskForm, icon: const Icon(Icons.add)),
          const SizedBox(
            width: 10,
          )
        ],
        title: const Row(
          children: [
            Icon(Icons.lock),
            SizedBox(
              width: 5,
            ),
            Text("Crypton")
          ],
        ),
      ),
      body: Container(
        child: ListView(
          children: [
            ...tasks.map(
              (task) => Task(taskMetadata: task, delete: _delete),
            ),
          ],
        ),
      ),
    );
  }
}
