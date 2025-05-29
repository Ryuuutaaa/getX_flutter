import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/modules/home/controller.dart';
import 'package:getx_todolist/app/data/models/task.dart';

class DetailPage extends StatelessWidget {
  final homeCtrl = Get.find<HomeController>();

  DetailPage({super.key});

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
          Row(
            children: [
              Icon(
                IconData(
                  task.icon,
                  fontFamily: 'MaterialIcons',
                ),
                color: color,
              ),
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 12.0.sp,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          // Tambahkan isi detail lainnya di sini
        ],
      ),
    );
  }
}
