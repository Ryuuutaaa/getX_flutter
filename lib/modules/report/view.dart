import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/modules/home/controller.dart';

class ReportPage extends StatelessWidget {
  final homeCtrl = Get.find<HomeController>();
  ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () {
            var createdTasks = homeCtrl.getTotalTask();
            var complatedTasks = homeCtrl.getTotalDoneTask();
            var liveTasks = createdTasks - complatedTasks;
            var precent = (complatedTasks / createdTasks) * 100;
            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.0.wp),
                  child: Text(
                    'My Report',
                    style: TextStyle(
                      fontSize: 24.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
