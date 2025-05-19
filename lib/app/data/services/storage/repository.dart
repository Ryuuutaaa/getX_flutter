import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/app/data/providers/task/provider.dart';

class TaskRepository {
  final TaskProvider taskProvider;

  TaskRepository({required this.taskProvider});

  List<Task> readTask() => taskProvider.readTask();

  void writeTasks(List<Task> tasks) => taskProvider.writeTasks(tasks);
}

