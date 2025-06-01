import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/app/data/services/storage/repository.dart';

class HomeController extends GetxController {
  final TaskRepository taskRepository;

  HomeController({required this.taskRepository});

  // Form and UI state
  final formKey = GlobalKey<FormState>();
  final editCtrl = TextEditingController();
  final tabIndex = 0.obs;
  final chipIndex = 0.obs;
  final deleting = false.obs;

  // Task and todo data
  final tasks = <Task>[].obs;
  final task = Rx<Task?>(null);
  final doingTodos = <dynamic>[].obs;
  final doneTodos = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTasks();
    _setupTaskWatcher();
  }

  @override
  void onClose() {
    editCtrl.dispose();
    super.onClose();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  // Private methods
  void _loadTasks() {
    try {
      final loadedTasks = taskRepository.readTask();
      tasks.assignAll(loadedTasks);
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  void _setupTaskWatcher() {
    ever(tasks, (_) {
      try {
        taskRepository.writeTasks(tasks);
      } catch (e) {
        debugPrint('Error saving tasks: $e');
      }
    });
  }

  // UI state management
  void changeChipIndex(int value) {
    if (value >= 0) {
      chipIndex.value = value;
    }
  }

  void changeDeleting(bool value) {
    deleting.value = value;
  }

  void changeTask(Task? select) {
    task.value = select;
  }

  void changeTodos(List<dynamic> select) {
    doingTodos.clear();
    doneTodos.clear();

    for (final todo in select) {
      if (todo is Map<String, dynamic> && todo.containsKey('done')) {
        if (todo['done'] == true) {
          doneTodos.add(todo);
        } else {
          doingTodos.add(todo);
        }
      }
    }
  }

  // Task management
  bool addTask(Task newTask) {
    if (tasks.any((existingTask) => existingTask.title == newTask.title)) {
      return false;
    }
    tasks.add(newTask);
    return true;
  }

  void deleteTask(Task taskToDelete) {
    tasks.removeWhere((task) => task.title == taskToDelete.title);
  }

  bool updateTask(Task taskToUpdate, String newTodoTitle) {
    if (newTodoTitle.trim().isEmpty) {
      return false;
    }

    final todos = List<Map<String, dynamic>>.from(taskToUpdate.todos ?? []);

    // Check if todo already exists
    if (todos.any((todo) => todo['title'] == newTodoTitle.trim())) {
      return false;
    }

    // Add new todo
    final newTodo = {'title': newTodoTitle.trim(), 'done': false};
    todos.add(newTodo);

    // Update task
    final updatedTask = taskToUpdate.copyWith(todos: todos);
    final taskIndex =
        tasks.indexWhere((task) => task.title == taskToUpdate.title);

    if (taskIndex != -1) {
      tasks[taskIndex] = updatedTask;
      tasks.refresh();
      return true;
    }
    return false;
  }

  // Todo management
  bool addTodo(String title) {
    if (title.trim().isEmpty) {
      return false;
    }

    final trimmedTitle = title.trim();
    final newTodo = {'title': trimmedTitle, 'done': false};
    final doneTodo = {'title': trimmedTitle, 'done': true};

    // Check if todo already exists in either list
    final existsInDoing = doingTodos.any((element) =>
        element is Map<String, dynamic> && element['title'] == trimmedTitle);
    final existsInDone = doneTodos.any((element) =>
        element is Map<String, dynamic> && element['title'] == trimmedTitle);

    if (existsInDoing || existsInDone) {
      return false;
    }

    doingTodos.add(newTodo);
    return true;
  }

  void updateTodos() {
    if (task.value == null) return;

    final newTodos = <Map<String, dynamic>>[];

    // Add doing todos
    for (final todo in doingTodos) {
      if (todo is Map<String, dynamic>) {
        newTodos.add(Map<String, dynamic>.from(todo));
      }
    }

    // Add done todos
    for (final todo in doneTodos) {
      if (todo is Map<String, dynamic>) {
        newTodos.add(Map<String, dynamic>.from(todo));
      }
    }

    final newTask = task.value!.copyWith(todos: newTodos);
    final oldIndex = tasks.indexWhere((t) => t.title == task.value!.title);

    if (oldIndex != -1) {
      tasks[oldIndex] = newTask;
      task.value = newTask; // Update current task reference
      tasks.refresh();
    }
  }

  void doneTodo(String title) {
    if (title.trim().isEmpty) return;

    final trimmedTitle = title.trim();
    final doingTodo = {'title': trimmedTitle, 'done': false};

    final index = doingTodos.indexWhere((element) =>
        element is Map<String, dynamic> && element['title'] == trimmedTitle);

    if (index != -1) {
      doingTodos.removeAt(index);
      final doneTodo = {'title': trimmedTitle, 'done': true};
      doneTodos.add(doneTodo);

      doingTodos.refresh();
      doneTodos.refresh();
    }
  }

  void deleteDoneTodo(dynamic todoToDelete) {
    if (todoToDelete is! Map<String, dynamic>) return;

    final index = doneTodos.indexWhere((element) =>
        element is Map<String, dynamic> &&
        element['title'] == todoToDelete['title']);

    if (index != -1) {
      doneTodos.removeAt(index);
      doneTodos.refresh();
    }
  }

  void undoTodo(String title) {
    if (title.trim().isEmpty) return;

    final trimmedTitle = title.trim();
    final index = doneTodos.indexWhere((element) =>
        element is Map<String, dynamic> && element['title'] == trimmedTitle);

    if (index != -1) {
      doneTodos.removeAt(index);
      final doingTodo = {'title': trimmedTitle, 'done': false};
      doingTodos.add(doingTodo);

      doingTodos.refresh();
      doneTodos.refresh();
    }
  }

  // Utility methods
  bool isTodosEmpty(Task task) => task.todos == null || task.todos!.isEmpty;

  int getDoneTodo(Task task) {
    if (task.todos == null || task.todos!.isEmpty) return 0;

    return task.todos!
        .where((todo) => todo is Map<String, dynamic> && todo['done'] == true)
        .length;
  }

  int getTotalTodos(Task task) => task.todos?.length ?? 0;

  double getTaskProgress(Task task) {
    final total = getTotalTodos(task);
    if (total == 0) return 0.0;

    final completed = getDoneTodo(task);
    return completed / total;
  }

  bool isTaskCompleted(Task task) {
    final total = getTotalTodos(task);
    if (total == 0) return false;

    return getDoneTodo(task) == total;
  }

  // Validation methods
  bool isValidTodoTitle(String title) {
    return title.trim().isNotEmpty && title.trim().length <= 100;
  }

  bool isValidTaskTitle(String title) {
    return title.trim().isNotEmpty && title.trim().length <= 50;
  }

  void uncompleteTodo(Map<String, dynamic> todo) {
    try {
      // 1. Hapus dari doneTodos
      final index = doneTodos.indexWhere((element) =>
          element is Map<String, dynamic> && element['title'] == todo['title']);

      if (index != -1) {
        doneTodos.removeAt(index);

        // 2. Tambahkan ke doingTodos dengan status done: false
        final updatedTodo = {'title': todo['title'], 'done': false};
        doingTodos.add(updatedTodo);

        // 3. Update di task yang aktif
        if (task.value != null) {
          final taskIndex =
              tasks.indexWhere((t) => t.title == task.value!.title);
          if (taskIndex != -1) {
            final updatedTodos = tasks[taskIndex].todos?.map((t) {
              if (t is Map<String, dynamic> &&
                  t['title'] == todo['title'] &&
                  t['done'] == true) {
                return {'title': t['title'], 'done': false};
              }
              return t;
            }).toList();

            final updatedTask = tasks[taskIndex].copyWith(todos: updatedTodos);
            tasks[taskIndex] = updatedTask;
            task.value = updatedTask;
          }
        }

        // 4. Update UI
        doingTodos.refresh();
        doneTodos.refresh();
        tasks.refresh();

        // 5. Tampilkan notifikasi
        Get.snackbar(
          'Task Dipulihkan',
          'Tugas "${todo['title']}" telah dikembalikan ke daftar aktif',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error in uncompleteTodo: $e');
      Get.snackbar(
        'Error',
        'Gagal memulihkan tugas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  int getTotalTask() {
    return tasks.fold<int>(
      0,
      (previousValue, task) => previousValue + (task.todos?.length ?? 0),
    );
  }

  int getTotalDoneTask() {
    var res = 0;
    for (var task in tasks) {
      if (task.todos != null) {
        for (var todo in task.todos!) {
          if (todo is Map<String, dynamic> && todo['done'] == true) {
            res++;
          }
        }
      }
    }
    return res;
  }
}
