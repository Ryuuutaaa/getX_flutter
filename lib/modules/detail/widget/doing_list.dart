import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/modules/home/controller.dart';

class DoingList extends StatelessWidget {
  final homeCtrl = Get.find<HomeController>();

  DoingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final doingTodos = homeCtrl.doingTodos;
        final doneTodos = homeCtrl.doneTodos;

        if (doingTodos.isEmpty && doneTodos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/task.png',
                  width: 65.0.wp,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 5.0.wp),
                Text(
                  "Add Task",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: doingTodos.length,
          itemBuilder: (context, index) {
            final todo = doingTodos[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: 2.0.wp,
                horizontal: 5.0.wp,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      value: todo['done'],
                      onChanged: (value) {
                        homeCtrl.doneTodo(todo['title']);
                      },
                    ),
                  ),
                  SizedBox(width: 4.0.wp),
                  Expanded(
                    child: Text(
                      todo['title'],
                      style: TextStyle(
                        fontSize: 12.0.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
