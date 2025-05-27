import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/app/data/models/task.dart';
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
    final completedTasks =
        task.todos?.where((todo) => todo.done == true).length ?? 0;
    final totalTasks = task.todos?.length ?? 0;

    return Container(
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
                // Progress indicator
                SizedBox(
                  width: 12.0.wp,
                  child: StepProgressIndicator(
                    totalSteps: 100,
                    currentStep: totalTasks > 0
                        ? (completedTasks / totalTasks * 100).round()
                        : 0,
                    size: 8,
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
                ),
              ],
            ),

            SizedBox(height: 4.0.wp),

            // Task title
            Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0.sp,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),

            const Spacer(),

            // Task count at bottom
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 12.0.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 1.0.wp),
                Text(
                  '$completedTasks/$totalTasks Tasks',
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
    );
  }
}
