import 'package:crypton/model/task_settings.dart';
import 'package:crypton/widget/task.dart';

enum TaskStatus {
  idle,
  processing,
  error,
  done,
}

class TaskMetadata {
  TaskMetadata({required this.taskSettings, required this.status});

  final TaskSettings taskSettings;
  TaskStatus status;
}
