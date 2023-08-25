import 'package:crypton/model/task_settings.dart' as TS;
import 'package:crypton/service/encryption_decryption_service.dart';
import 'package:crypton/widget/new_task_form.dart';
import 'package:crypton/widget/task.dart';
import 'package:crypton/model/task_metadata.dart';
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

  bool _isProcessingStarted = false;
  bool _forceStop = false;

  void _showNewTaskForm() {
    showGeneralDialog(
        context: context,
        pageBuilder: _newTaskFormBuilder,
        barrierDismissible: false);
  }

  Widget _newTaskFormBuilder(BuildContext context, Animation<double> animation,
      Animation<double> animation2) {
    return NewTaskForm(
      runNewTask: _addNewTask,
    );
  }

  void _addNewTask(TS.TaskSettings taskSettings) async {
    setState(() {
      tasks.add(
          TaskMetadata(taskSettings: taskSettings, status: TaskStatus.idle));
    });
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
            Text("Version: 0.3.0 (2023)"),
          ],
        ));
  }

  Widget _alertNoTaskDialogBuilder(BuildContext context) {
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
      ],
      content: const Text(
        "Please first define a task",
      ),
    );
  }

  Widget _alertRunTaskDialogBuilder(BuildContext context) {
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
            onPressed: _proceedWithProcessingData,
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
                " Moreover the author of this software is not responsible for any data loss produced by this application.")
          ],
        ));
  }

  void _proceedWithProcessingData() async {
    setState(() {
      _execute();
    });

    Navigator.of(context).pop();
  }

  Future<void> _execute() async {
    setState(() {
      _isProcessingStarted = true;
    });
    for (TaskMetadata task in tasks) {
      if (_forceStop) {
        setState(() {
          _forceStop = false;
          _isProcessingStarted = false;
        });
        return;
      }
      if (task.status == TaskStatus.done || task.status == TaskStatus.error) {
        continue;
      }

      setState(() {
        task.status = TaskStatus.processing;
      });
      try {
        await EncryptionDecryptionService.executeTaskEncryption(
            task.taskSettings);
      } on Error catch (_) {
        setState(() {
          task.status = TaskStatus.error;
        });
        continue;
      }
      setState(
        () {
          task.taskSettings.files = [...task.taskSettings.files];
          if (task.taskSettings.files
              .where((element) => element.message != null)
              .isNotEmpty) {
            task.status = TaskStatus.error;
          } else {
            task.status = TaskStatus.done;
          }
        },
      );
    }
    setState(() {
      _isProcessingStarted = false;
    });
  }

  void _delete(TaskMetadata taskMetadata) {
    setState(() {
      tasks.remove(taskMetadata);
    });
  }

  void _startProcessing() {
    setState(() {
      _forceStop = false;
    });
    showDialog(
        context: context,
        builder: tasks.isEmpty
            ? _alertNoTaskDialogBuilder
            : _alertRunTaskDialogBuilder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          tasks.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(10),
                  child: OutlinedButton(
                      style: const ButtonStyle(
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.white),
                          side: MaterialStatePropertyAll(BorderSide(
                              width: 1.0,
                              color: Color.fromARGB(255, 255, 255, 255)))),
                      onPressed: () {
                        setState(
                          () {
                            tasks = [];
                          },
                        );
                      },
                      child: const Text("Clear all tasks")),
                )
              : const SizedBox(),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: _aboutDialogBuilder,
              );
            },
            icon: const Icon(Icons.info),
          ),
          IconButton(
              onPressed: _isProcessingStarted ? null : _showNewTaskForm,
              icon: Icon(
                Icons.add,
                color: _isProcessingStarted
                    ? const Color.fromARGB(102, 255, 254, 254)
                    : null,
              )),
          const SizedBox(
            width: 10,
          )
        ],
        title: Row(
          children: [
            Image.asset(
              "assets/images/icon-48.png",
              width: 48,
              height: 48,
            ),
            const SizedBox(
              width: 5,
            ),
            const Text("Crypton")
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: const Color.fromARGB(255, 0, 0, 0))),
        child: tasks.isEmpty
            ? Center(
                child: OutlinedButton(
                  onPressed: _showNewTaskForm,
                  child: const Text("Add new encryption / decryption task"),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: _taskListBuilder,
                      itemCount: tasks.length,
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.black, width: 1))),
                      child: _retrieveActionButton()),
                ],
              ),
      ),
    );
  }

  Widget _taskListBuilder(BuildContext context, int index) {
    return Task(
        taskMetadata: tasks[index],
        delete: _delete,
        isProcessingStarted: _isProcessingStarted);
  }

  Widget _retrieveActionButton() {
    if (_isProcessingStarted) {
      return FilledButton(
        style: const ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(Colors.white),
          backgroundColor: MaterialStatePropertyAll(
            Color.fromARGB(255, 201, 7, 7),
          ),
        ),
        onPressed: _stopProcessing,
        child: _forceStop
            ? const Text("Please wait until current job ends")
            : const Text("Stop processing"),
      );
    }

    return FilledButton(
      style: ButtonStyle(
        foregroundColor: const MaterialStatePropertyAll(Colors.white),
        backgroundColor: _isProcessingStarted
            ? const MaterialStatePropertyAll(
                Color.fromARGB(
                  66,
                  27,
                  26,
                  26,
                ),
              )
            : const MaterialStatePropertyAll(
                Color.fromARGB(
                  255,
                  7,
                  133,
                  201,
                ),
              ),
      ),
      onPressed: _isProcessingStarted ? null : _startProcessing,
      child: const Text("Start processing"),
    );
  }

  void _stopProcessing() {
    setState(() {
      _forceStop = true;
    });
  }
}
