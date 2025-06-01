import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/modules/home/controller.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ReportPage extends GetView<HomeController> {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Text(
          'No Report Data Available',
          style: TextStyle(
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
