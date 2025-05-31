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
          if (doingTodos.isNotEmpty) ..._buildDoingTodosList(doingTodos),
          if (doingTodos.isNotEmpty && doneTodos.isNotEmpty)
            const Divider(thickness: 1, height: 1),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(8.0.wp),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/task.png',
              width: 65.0.wp,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4.0.wp),
            Text(
              "Add Task",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 2.0.wp),
            Text(
              "You don't have any tasks yet",
              style: TextStyle(
                fontSize: 10.0.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDoingTodosList(List<dynamic> todos) {
    return todos.map((todo) => _buildTodoItem(todo)).toList(growable: false);
  }

  Widget _buildTodoItem(Map<String, dynamic> todo) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => homeCtrl.doneTodo(todo['title']),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 1.5.wp,
            horizontal: 4.0.wp,
          ),
          child: Row(
            children: [
              _buildCheckbox(todo),
              SizedBox(width: 3.0.wp),
              _buildTodoText(todo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(Map<String, dynamic> todo) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Checkbox(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        value: todo['done'],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: (value) => homeCtrl.doneTodo(todo['title']),
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue;
          }
          return Colors.grey[300]!;
        }),
      ),
    );
  }

  Widget _buildTodoText(Map<String, dynamic> todo) {
    return Expanded(
      child: Text(
        todo['title'],
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          fontSize: 11.0.sp,
          decoration: todo['done'] ? TextDecoration.lineThrough : null,
          color: todo['done'] ? Colors.grey[600] : Colors.black87,
        ),
      ),
    );
  }
}
