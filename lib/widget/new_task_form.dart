import 'dart:convert';

import 'package:crypton/model/file_metadata.dart';
import 'package:crypton/model/task_settings.dart' as TS;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class NewTaskForm extends StatefulWidget {
  const NewTaskForm({super.key, required this.runNewTask});
  final Function(TS.TaskSettings) runNewTask;

  @override
  State<StatefulWidget> createState() {
    return _FormNewDialogState();
  }
}

class _FormNewDialogState extends State<NewTaskForm> {
  TS.Action _action = TS.Action.encrypt;
  List<FileMetadata> _files = [];
  TS.Algorithm _algorithm = TS.Algorithm.aes;
  bool _isDeleteOriginalFilesOnCompletion = false;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _passwordController.dispose();
    super.dispose();
  }

  Widget _validationFormErrorDialogBuilder(BuildContext context) {
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
              "Please select at least one file in order to proceed with the creation of the task.",
            ),
          ],
        ));
  }

  void _chooseFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _files = result.files
            .map((platformFile) => FileMetadata(platformFile: platformFile))
            .toList();
      });
    }
  }

  void _submit() {
    if (_files.isEmpty) {
      showDialog(context: context, builder: _validationFormErrorDialogBuilder);
      return;
    }
    final String newPassword =
        _calculatePassword(_algorithm, _passwordController.text);
    widget.runNewTask(TS.TaskSettings(
        action: _action,
        algorithm: _algorithm,
        files: _files,
        password: newPassword,
        isDeleteOriginalFilesOnCompletion: _isDeleteOriginalFilesOnCompletion));
    Navigator.of(context).pop();
  }

  String _calculatePassword(TS.Algorithm algorithm, String password) {
    if (TS.Algorithm.aes == algorithm) {
      return password.padRight(32, "x");
    }
    if (TS.Algorithm.fernet == algorithm) {
      String calculatedPassword = base64Url.encode(utf8.encode(password));
      while (calculatedPassword.length < 32) {
        password = "${password}x";
        calculatedPassword = base64Url.encode(utf8.encode(password));
      }
      return password;
    }
    if (TS.Algorithm.salsa == algorithm) {
      return password.padRight(32, "x");
    }
    throw Exception("Invalid algorithm 7");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        OutlinedButton(onPressed: _submit, child: const Text("Add Task"))
      ],
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text("Add new encryption/decryption task."),
            const SizedBox(
              height: 20,
            ),
            const Row(
              children: [
                Text(
                  "1 - Select an operation:",
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Row(
                  children: [
                    Radio<TS.Action>(
                      value: TS.Action.encrypt,
                      groupValue: _action,
                      onChanged: (TS.Action? value) {
                        setState(() {
                          _action = value!;
                        });
                      },
                    ),
                    const Text("Encrypt"),
                  ],
                ),
                Row(
                  children: [
                    Radio<TS.Action>(
                      value: TS.Action.decrypt,
                      groupValue: _action,
                      onChanged: (TS.Action? value) {
                        setState(() {
                          _action = value!;
                        });
                      },
                    ),
                    const Text("Decrypt"),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 400,
              child: Column(
                children: [
                  const Text(
                    "2 - Choose one or more files that you want to encrypt/decrypt",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: 380,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: const Color.fromARGB(255, 0, 0, 0))),
                        child: ListView.builder(
                          itemBuilder: _fileListBuilder,
                          itemCount: _files.length,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _chooseFile();
                        },
                        child: const Text("Choose file/s"),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Text("3 - Choose preferred Algorithm: "),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  DropdownMenu<TS.Algorithm>(
                    width: 400,
                    initialSelection: TS.Algorithm.aes,
                    onSelected: (TS.Algorithm? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        _algorithm = value!;
                      });
                    },
                    dropdownMenuEntries: TS.Algorithm.values
                        .map<DropdownMenuEntry<TS.Algorithm>>(
                            (TS.Algorithm algorithm) {
                      return DropdownMenuEntry<TS.Algorithm>(
                          value: algorithm,
                          label: algorithm.name.toUpperCase());
                    }).toList(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Text("4 - input a Password"),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Password",
                      ),
                      maxLength: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Checkbox(
                  value: _isDeleteOriginalFilesOnCompletion,
                  onChanged: (value) {
                    setState(() {
                      _isDeleteOriginalFilesOnCompletion = value!;
                    });
                  },
                ),
                Text(
                  "Delete original file/s on complete encryption/decryption",
                  style: TextStyle(
                      color: _isDeleteOriginalFilesOnCompletion
                          ? Colors.red
                          : null),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              width: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "The author of this software is not responsible for any data loss.",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileListBuilder(BuildContext context, int index) {
    if (_files.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: const Text(
          "No file selected",
          style: TextStyle(color: Color.fromARGB(105, 0, 0, 0)),
        ),
      );
    }
    return Card(
      child: Text(
        _files[index].platformFile.name,
      ),
    );
  }
}
