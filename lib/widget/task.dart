import 'package:crypton/model/task_metadata.dart';
import 'package:flutter/material.dart';

class Task extends StatelessWidget {
  Task(
      {super.key,
      required this.taskMetadata,
      required this.delete,
      required this.isProcessingStarted});
  final DateTime dateTime = DateTime.now();
  final TaskMetadata taskMetadata;
  final Function(TaskMetadata) delete;
  final bool isProcessingStarted;

  bool get isTaskDone {
    return taskMetadata.status == TaskStatus.done;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: isTaskDone
            ? const BoxDecoration(color: Color.fromARGB(61, 186, 184, 184))
            : null,
        padding: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: _calculateStatusIcon(taskMetadata.status),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  taskMetadata.taskSettings.action.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  taskMetadata.taskSettings.algorithm.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.watch_outlined),
                    Text(dateTime.toIso8601String())
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    isProcessingStarted ? null : delete(taskMetadata);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: isProcessingStarted
                        ? const Color.fromARGB(30, 244, 67, 54)
                        : Colors.red,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(66, 0, 0, 0))),
                    height: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: _buildFilesListView,
                      itemCount: taskMetadata.taskSettings.files.length,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilesListView(BuildContext context, int index) {
    final file = taskMetadata.taskSettings.files[index];
    final color = file.errorMessage != null
        ? const Color.fromRGBO(255, 17, 0, 0.456)
        : null;
    final filename = '${file.errorMessage ?? ''}${file.platformFile.path!}';
    return Card(
      color: color,
      child: Text(filename),
    );
  }

  Widget _calculateStatusIcon(TaskStatus status) {
    if (status == TaskStatus.idle) {
      return const Icon(Icons.enhanced_encryption, color: Colors.purple);
    } else if (TaskStatus.processing == status) {
      return const CircularProgressIndicator.adaptive(
        strokeWidth: 3,
        strokeCap: StrokeCap.square,
        strokeAlign: BorderSide.strokeAlignCenter,
      );
    } else if (status == TaskStatus.error) {
      return const Icon(Icons.error, color: Colors.red);
    } else if (status == TaskStatus.done) {
      return const Icon(
        Icons.done,
        color: Colors.green,
      );
    }

    return const Icon(Icons.device_unknown);
  }
}
