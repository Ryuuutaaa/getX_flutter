import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/modules/home/controller.dart';

class DoneList extends StatelessWidget {
  final homeCtrl = Get.find<HomeController>();
  DoneList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => homeCtrl.doneTodos.isNotEmpty
          ? ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                  Text(
                    'Completed (${homeCtrl.doneTodos.length})',
                    style: TextStyle(
                      fontSize: 14.0.wp,
                      color: Colors.grey,
                    ),
                  ),
                  ...homeCtrl.doneTodos.map((element) => Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: Icon(Icons.done),
                          ),
                          Text(
                            element['title'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ))
                ])
          : Container(),
    );
  }
}
