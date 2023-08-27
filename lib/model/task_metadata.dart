import 'package:crypton/model/task_settings.dart';

enum TaskStatus { idle, processing, error, done, warning }

class TaskMetadata {
  TaskMetadata({required this.taskSettings, required this.status});

  final TaskSettings taskSettings;
  TaskStatus status;
}
