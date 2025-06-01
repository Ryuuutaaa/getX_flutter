import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/modules/home/controller.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/modules/home/widget/add_card.dart';
import 'package:getx_todolist/modules/home/widget/add_dialog.dart';
import 'package:getx_todolist/modules/home/widget/task_card.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:getx_todolist/modules/report/view.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0.wp),
                    child: Text(
                      "My list",
                      style: TextStyle(
                        fontSize: 24.0.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(
                    () => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0.wp),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 4.0.wp,
                        mainAxisSpacing: 4.0.wp,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ...controller.tasks.map(
                            (task) => LongPressDraggable<Task>(
                              data: task,
                              onDragStarted: () =>
                                  controller.changeDeleting(true),
                              onDraggableCanceled: (_, __) =>
                                  controller.changeDeleting(false),
                              onDragEnd: (_) =>
                                  controller.changeDeleting(false),
                              feedback: Material(
                                color: Colors.transparent,
                                child: Transform.scale(
                                  scale: 1.1,
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: TaskCard(task: task),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: TaskCard(task: task),
                              ),
                              child: TaskCard(task: task),
                            ),
                          ),
                          AddCard(),
                        ],
                      ),
                    ),
                  ),
                  // Add bottom padding to prevent overlap with bottom navigation bar
                  SizedBox(height: 140),
                ],
              ),

              // Drag Target for deletion - positioned at bottom of screen
              Obx(
                () => controller.deleting.value
                    ? Positioned(
                        bottom:
                            80, // Adjusted to be above the bottom navigation bar
                        left: 0,
                        right: 0,
                        child: DragTarget<Task>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              height: 100,
                              margin: EdgeInsets.all(4.0.wp),
                              decoration: BoxDecoration(
                                color: candidateData.isNotEmpty
                                    ? Colors.red.withOpacity(0.8)
                                    : Colors.red.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      candidateData.isNotEmpty
                                          ? "Release to Delete"
                                          : "Drag here to Delete",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onWillAccept: (data) => data is Task,
                          onAccept: (Task task) {
                            // Add confirmation dialog
                            Get.defaultDialog(
                              title: "Delete Task",
                              middleText:
                                  "Are you sure you want to delete '${task.title}'?",
                              textConfirm: "Delete",
                              textCancel: "Cancel",
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.red,
                              onConfirm: () {
                                controller.deleteTask(task);
                                EasyLoading.showSuccess(
                                    'Task deleted successfully');
                                Get.back();
                              },
                            );
                            controller.changeDeleting(false);
                          },
                          onLeave: (data) {
                            // Optional: Add visual feedback when item leaves target
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        floatingActionButton: Obx(
          () => controller.deleting.value
              ? const SizedBox.shrink() // Hide FAB when in delete mode
              : FloatingActionButton(
                  onPressed: () {
                    if (controller.tasks.isNotEmpty) {
                      Get.to(() => AddDialog(),
                          transition: Transition.downToUp);
                    } else {
                      EasyLoading.showInfo("Please create you task type");
                    }
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add),
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // Bottom Navigation Bar
        // Pada bagian bottomNavigationBar di home/view.dart
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    // Gunakan Get.offAll() untuk menghapus semua halaman sebelumnya
                    Get.offAll(() => HomePage());
                  },
                  color: Colors.blue,
                ),
                SizedBox(width: 40), // Space for FAB (Add button)
                IconButton(
                  icon: Icon(Icons.bar_chart),
                  onPressed: () {
                    // Navigasi ke ReportPage
                    Get.to(() => ReportPage());
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
