import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/modules/home/controller.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: ListView(
        children: [
          Text(
            "My list",
            style: TextStyle(
              fontSize: 24.0.sp,
            ),
          ),
        ],
      ),
    ));
  }
}
