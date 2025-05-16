import 'dart:convert';

import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/keys.dart';
import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/app/data/services/storage/services.dart';

class TaskProvider {
  final StorageServices _storage = Get.find<StorageServices>();

  List<Task> readTask() {
    var tasks = <Task>[];

    jsonDecode(_storage.read(taskKey).toString())
        .forEach((e) => tasks.add(Task.fromJson(e)));
    return tasks;
  }
}
