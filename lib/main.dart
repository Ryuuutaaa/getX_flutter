import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/modules/home/view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      title: "Todo list using GetX",
      home: HomePage(),
    );
  }
}
