import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/modules/home/controller.dart';

class DoingList extends StatelessWidget {
  final HomeController homeCtrl = Get.find<HomeController>();

  DoingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doingTodos = homeCtrl.doingTodos;
      final doneTodos = homeCtrl.doneTodos;

      if (doingTodos.isEmpty && doneTodos.isEmpty) {
        return _buildEmptyState();
      }

      return ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          if (doingTodos.isNotEmpty)
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 4.0.wp, vertical: 2.0.wp),
              child: Text(
                "Tasks To Do (${doingTodos.length})",
                style: TextStyle(
                  fontSize: 12.0.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          if (doingTodos.isNotEmpty) ..._buildDoingTodosList(doingTodos),
          if (doingTodos.isNotEmpty && doneTodos.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0.wp),
              child: Divider(
                thickness: 1,
                height: 1,
                color: Colors.grey[300],
                indent: 16.0.wp,
                endIndent: 16.0.wp,
              ),
            ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(12.0.wp),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/task.png',
              width: 65.0.wp,
              fit: BoxFit.contain,
              color: Colors.grey[400],
            ),
            SizedBox(height: 6.0.wp),
            Text(
              "No Tasks Yet",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 2.0.wp),
            Text(
              "Add your first task to get started",
              style: TextStyle(
                fontSize: 12.0.sp,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 4.0.wp),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDoingTodosList(List<dynamic> todos) {
    return todos.map((todo) => _buildTodoItem(todo)).toList(growable: false);
  }

  Widget _buildTodoItem(Map<String, dynamic> todo) {
    return Dismissible(
      key: ValueKey(
          todo['id'] ?? todo['title']), // Gunakan ValueKey dengan id atau title
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.wp),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 6.0.wp),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
              AlertDialog(
                title: const Text("Delete Task"),
                content:
                    const Text("Are you sure you want to delete this task?"),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        // Cek apakah todo ada di doing list
        final inDoingList = homeCtrl.doingTodos.any((element) =>
            element is Map<String, dynamic> &&
            element['title'] == todo['title']);

        if (inDoingList) {
          homeCtrl.deleteDoneTodo(todo); // Tetap bisa digunakan
          Get.snackbar(
            "Task Deleted",
            "Task '${todo['title']}' has been deleted",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => homeCtrl.doneTodo(todo['title']),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: 0.5.wp,
              horizontal: 4.0.wp,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 2.5.wp,
              horizontal: 4.0.wp,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildCheckbox(todo),
                SizedBox(width: 4.0.wp),
                _buildTodoText(todo),
                if (todo['done'] == true) ...[
                  const Spacer(),
                  Icon(
                    Icons.check_circle,
                    size: 16.0.sp,
                    color: Colors.green[400],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(Map<String, dynamic> todo) {
    final isDone = todo['done'] ?? false;

    return GestureDetector(
      onTap: () => homeCtrl.doneTodo(todo['title']),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDone ? Colors.blue : Colors.grey[400]!,
            width: 1.5,
          ),
          color: isDone ? Colors.blue : Colors.transparent,
        ),
        child: isDone
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildTodoText(Map<String, dynamic> todo) {
    final isDone = todo['done'] ?? false;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todo['title'] ?? '',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12.0.sp,
              fontWeight: FontWeight.w500,
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone ? Colors.grey[500] : Colors.grey[800],
            ),
          ),
          if (todo['description'] != null &&
              todo['description'].toString().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 0.5.wp),
              child: Text(
                todo['description'],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.0.sp,
                  color: Colors.grey[500],
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
