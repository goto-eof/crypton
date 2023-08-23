import 'package:crypton/model/task_settings.dart';
import 'package:crypton/widget/task_metadata.dart';
import 'package:flutter/material.dart';

class Task extends StatelessWidget {
  Task({super.key, required this.taskMetadata, required this.delete});
  final DateTime dateTime = DateTime.now();
  final TaskMetadata taskMetadata;
  final Function(TaskMetadata) delete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
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
                Text(taskMetadata.taskSettings.action.name),
                const SizedBox(
                  width: 10,
                ),
                Text(taskMetadata.taskSettings.algorithm.name),
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
                    delete(taskMetadata);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black)),
                    height: 100,
                    child: ListView(
                      children: [
                        ...taskMetadata.taskSettings.files.map((e) => Row(
                              children: [Text(e.path!)],
                            ))
                      ],
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

  Widget _calculateStatusIcon(TaskStatus status) {
    if (status == TaskStatus.idle) {
      return const Icon(Icons.watch_rounded);
    } else if (TaskStatus.processing == status) {
      return const CircularProgressIndicator.adaptive(
        strokeWidth: 3,
        strokeCap: StrokeCap.square,
        strokeAlign: BorderSide.strokeAlignCenter,
      );
    } else if (status == TaskStatus.error) {
      return const Icon(Icons.error);
    } else if (status == TaskStatus.done) {
      return const Icon(Icons.done);
    }

    return const Icon(Icons.device_unknown);
  }
}
