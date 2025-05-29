import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/modules/home/controller.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class DetailPage extends StatelessWidget {
  final HomeController homeCtrl = Get.find();

  DetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Task? task = homeCtrl.task.value;

    if (task == null) {
      return Scaffold(
        body: Center(
          child: Text('No task selected'),
        ),
      );
    }

    final color = HexColor.fromHex(task.color);

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                    homeCtrl.changeTask(null);
                  },
                  icon: Icon(Icons.arrow_back),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.wp),
            child: Row(
              children: [
                Icon(
                  IconData(
                    task.icon,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: color,
                ),
                SizedBox(width: 3.0.wp),
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16.0.wp,
              top: 3.0.wp,
              right: 16.0.wp,
            ),
            child: Obx(
              () => Row(
                children: [
                  Text(
                    '${homeCtrl.doingTodos.length + homeCtrl.doneTodos.length} Task',
                    style: TextStyle(
                      fontSize: 12.0.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 3.0.wp),
                  Expanded(
                    child: StepProgressIndicator(
                      totalSteps: (homeCtrl.doingTodos.length +
                              homeCtrl.doneTodos.length)
                          .clamp(1, double.infinity)
                          .toInt(),
                      currentStep: homeCtrl.doneTodos.length,
                      size: 5,
                      padding: 0,
                      selectedGradientColor: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.5),
                          color,
                        ],
                      ),
                      unselectedGradientColor: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[300]!,
                          Colors.grey[300]!,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
