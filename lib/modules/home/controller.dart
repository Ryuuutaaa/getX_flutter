import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/app/data/services/storage/repository.dart';

class HomeController extends GetxController {
  TaskRepository taskRepository;
  HomeController({required this.taskRepository});

  final formKey = GlobalKey<FormState>();
  final editCtrl = TextEditingController();
  final chipIndex = 0.obs;
  final deleting = false.obs;
  final tasks = <Task>[].obs;
  final task = Rx<Task?>(null);
  final doingTodos = <dynamic>[].obs;
  final doneTodos = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    tasks.assignAll(taskRepository.readTask());
    ever(tasks, (_) => taskRepository.writeTasks(tasks));
  }

  @override
  void onClose() {
    super.onClose();
  }

  void changeChipIndex(int value) {
    chipIndex.value = value;
  }

  void changeDeleting(bool value) {
    deleting.value = value;
  }

  void changeTask(Task? select) {
    task.value = select;
  }

  void changeTodos(List<dynamic> select) {
    doingTodos.clear();
    doingTodos.clear();
    for (int i = 0; i < select.length; i++) {
      var todo = select[i];
      var stataus = todo['done'];

      if (stataus == true) {
        doneTodos.add(todo);
      } else {
        doingTodos.add(todo);
      }
    }
  }

  bool addTask(Task task) {
    if (tasks.contains(task)) {
      return false;
    }

    tasks.add(task);
    return true;
  }

  void deleteTask(Task task) {
    tasks.remove(task);
  }

  bool updateTask(Task task, String title) {
    final todos = task.todos ?? [];

    if (todos.any((todo) => todo['title'] == title)) {
      return false;
    }

    final newTodo = {'title': title, 'done': false};

    todos.add(newTodo);
    final updatedTask = task.copyWith(todos: todos);
    final taskIndex = tasks.indexOf(task);
    if (taskIndex != -1) {
      tasks[taskIndex] = updatedTask;
      tasks.refresh();
    }
    return true;
  }

  bool addTodo(String title) {
    var todo = {'title': title, 'done': false};

    if (doingTodos
        .any((element) => mapEquals<String, dynamic>(todo, element))) {
      return false;
    }

    var doneTodo = {'title': title, 'done': true};
    if (doneTodos
        .any((element) => mapEquals<String, dynamic>(doneTodo, element))) {
      return false;
    }
    doingTodos.add(todo);
    return true;
  }

  void updateTodos() {
    var newTodos = <Map<String, dynamic>>[];
    newTodos.addAll(
      [
        ...doingTodos,
        ...doneTodos,
      ],
    );
    var newTask = task.value!.copyWith(todos: newTodos);
    int oldIdx = tasks.indexOf(task);
    tasks[oldIdx] = newTask;
    tasks.refresh();
  }

  void doneTodo(String title) {
    var doingTodo = {'title': title, 'done': false};

    int index = doingTodos.indexWhere(
      (element) => mapEquals<String, dynamic>(doingTodo, element),
    );

    if (index != -1) {
      doingTodos.removeAt(index);
      var doneTodo = {'title': title, 'done': true};
      doneTodos.add(doneTodo);
      doingTodos.refresh();
      doneTodos.refresh();
    }
  }

  void deleteTodo(String todo) {}
}
