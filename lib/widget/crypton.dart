import 'package:crypton/model/task_settings.dart' as TS;
import 'package:crypton/service/encryption_decryption_service.dart';
import 'package:crypton/widget/new_task_form.dart';
import 'package:crypton/widget/task.dart';
import 'package:crypton/widget/task_metadata.dart';
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
            Text("Version: 0.1.0 (2023)"),
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
            onPressed: () async {
              if (Navigator.of(context).mounted) {
                Navigator.of(context).pop();
              }

              for (TaskMetadata task in tasks) {
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
                  return;
                }
                setState(() {
                  task.status = TaskStatus.done;
                });
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
            icon: const Icon(Icons.info),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: tasks.isEmpty
                      ? _alertNoTaskDialogBuilder
                      : _alertRunTaskDialogBuilder);
            },
            icon: const Icon(Icons.play_arrow),
          ),
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
        child: tasks.isEmpty
            ? Center(
                child: OutlinedButton(
                  onPressed: _showNewTaskForm,
                  child: const Text("Add new encryption / decryption task"),
                ),
              )
            : ListView(
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
