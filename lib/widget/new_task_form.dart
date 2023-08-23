import 'dart:convert';

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
  List<PlatformFile> _files = [];
  TS.Algorithm _algorithm = TS.Algorithm.aes;
  String _encoded = "";

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _passwordController.dispose();
    super.dispose();
  }

  void _chooseFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _files = result.files;
      });
    }
  }

  void _submit() {
    final String _newPassword =
        _calculatePassword(_algorithm, _passwordController.text);
    widget.runNewTask(TS.TaskSettings(
      action: _action,
      algorithm: _algorithm,
      files: _files,
      password: _newPassword,
    ));
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Add new encryption/decryption task."),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 400,
            child: Column(
              children: [
                const Text("Action"),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        child: ListTile(
                          title: const Text('Encrypt'),
                          leading: Radio<TS.Action>(
                            value: TS.Action.encrypt,
                            groupValue: _action,
                            onChanged: (TS.Action? value) {
                              setState(() {
                                _action = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        child: ListTile(
                          title: const Text('Decrypt'),
                          leading: Radio<TS.Action>(
                            value: TS.Action.decrypt,
                            groupValue: _action,
                            onChanged: (TS.Action? value) {
                              setState(() {
                                _action = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 400,
            child: Column(
              children: [
                const Text("Choose one or more files"),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _chooseFile();
                      },
                      icon: const Icon(
                        Icons.file_open,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 100,
                      width: 300,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: const Color.fromARGB(255, 0, 0, 0))),
                      child: ListView(
                        children: [
                          ..._files
                              .where((element) => element.path != null)
                              .map(
                                (e) => Text(
                                  e.name,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 400,
            child: Row(
              children: [
                const Text("Algorithm: "),
                const SizedBox(
                  width: 10,
                ),
                DropdownMenu<TS.Algorithm>(
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
                        value: algorithm, label: algorithm.name);
                  }).toList(),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("data"),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _encoded = "${base64Url.encode(
                          utf8.encode(value ?? ''),
                        )} (${base64Url.encode(utf8.encode(value ?? '')).length})";
                      });
                    },
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
          SizedBox(
            width: 400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("data"),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: Text(
                    _encoded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
