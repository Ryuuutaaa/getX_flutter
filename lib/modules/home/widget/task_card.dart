import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/modules/detail/view.dart';
import 'package:getx_todolist/modules/home/controller.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class TaskCard extends StatelessWidget {
  final HomeController homeCtrl = Get.find();
  final Task task;

  TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final color = HexColor.fromHex(task.color);
    final squareWidth = Get.width - 12.0.wp;
    final completedTasks = homeCtrl.getDoneTodo(task);
    final totalTasks = task.todos?.length ?? 0;
    final hasValidTodos = totalTasks > 0;

    return GestureDetector(
      onTap: () {
        homeCtrl.changeTask(task);
        homeCtrl.changeTodos(task.todos ?? []);
        Get.to(() => DetailPage());
      },
      child: Container(
        width: squareWidth / 2,
        height: squareWidth / 2,
        margin: EdgeInsets.all(3.0.wp),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          border: Border(
            top: BorderSide(
              width: 3,
              color: color,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(5.0.wp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and progress
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.5.wp),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      IconData(task.icon, fontFamily: 'MaterialIcons'),
                      color: color,
                      size: 16.0.sp,
                    ),
                  ),
                  const Spacer(),
                  // Progress indicator - only show if there are valid todos
                  if (hasValidTodos)
                    SizedBox(
                      width: 12.0.wp,
                      child: StepProgressIndicator(
                        totalSteps: totalTasks,
                        currentStep: completedTasks,
                        size: 5,
                        padding: 0,
                        selectedGradientColor: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color.withOpacity(0.5), color],
                        ),
                        unselectedGradientColor: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.white],
                        ),
                      ),
                    )
                  else
                    // Show empty state indicator when no todos
                    Container(
                      width: 12.0.wp,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 4.0.wp),

              // Task title
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0.sp,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),

              SizedBox(height: 2.0.wp),

              // Task count at bottom
              Row(
                children: [
                  Icon(
                    hasValidTodos
                        ? Icons.check_circle_outline
                        : Icons.add_circle_outline,
                    size: 12.0.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 1.0.wp),
                  Text(
                    hasValidTodos
                        ? '$completedTasks/$totalTasks Tasks'
                        : 'No tasks yet',
                    style: TextStyle(
                      fontSize: 9.0.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
