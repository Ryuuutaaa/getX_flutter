import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
      body: Form(
        child: ListView(
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 2.0.wp,
                vertical: 5.0.wp,
              ),
              child: TextFormField(
                controller: homeCtrl.editCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.check_box_outline_blank,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (homeCtrl.formKey.currentState!.validate()) {
                        var success = homeCtrl.addTodo(homeCtrl.editCtrl.text);
                        if (success) {
                          EasyLoading.showSuccess("Todo item add success");
                        } else {
                          EasyLoading.showError("Todo item is already exist");
                        }
                        homeCtrl.editCtrl.clear();
                      }
                    },
                    icon: Icon(Icons.done),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your todo item";
                  }
                  return null;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
