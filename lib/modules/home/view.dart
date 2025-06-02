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
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade50,
                      Colors.grey.shade50,
                    ],
                    stops: const [0.0, 0.3],
                  ),
                ),
              ),

              ListView(
                padding: EdgeInsets.only(bottom: 140),
                children: [
                  // Header Section with enhanced styling
                  Container(
                    padding: EdgeInsets.all(6.0.wp),
                    margin: EdgeInsets.symmetric(
                        horizontal: 4.0.wp, vertical: 2.0.wp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back! 👋",
                              style: TextStyle(
                                fontSize: 16.0.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 1.0.wp),
                            Text(
                              "My Tasks",
                              style: TextStyle(
                                fontSize: 28.0.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(3.0.wp),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Obx(
                            () => Text(
                              "${controller.tasks.length}",
                              style: TextStyle(
                                fontSize: 18.0.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.0.wp),

                  // Tasks Grid with enhanced styling
                  Obx(
                    () => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0.wp),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 4.0.wp,
                        mainAxisSpacing: 4.0.wp,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 0.85,
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
                                    opacity: 0.9,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: TaskCard(task: task),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.4,
                                child: Transform.scale(
                                  scale: 0.95,
                                  child: TaskCard(task: task),
                                ),
                              ),
                              child: TaskCard(task: task),
                            ),
                          ),
                          AddCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Enhanced Drag Target for deletion
              Obx(
                () => controller.deleting.value
                    ? Positioned(
                        bottom: 80,
                        left: 6.0.wp,
                        right: 6.0.wp,
                        child: DragTarget<Task>(
                          builder: (context, candidateData, rejectedData) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: candidateData.isNotEmpty
                                      ? [
                                          Colors.red.shade600,
                                          Colors.red.shade400
                                        ]
                                      : [
                                          Colors.red.shade400,
                                          Colors.red.shade300
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        candidateData.isNotEmpty
                                            ? Icons.delete_forever
                                            : Icons.delete_outline,
                                        color: Colors.white,
                                        size:
                                            candidateData.isNotEmpty ? 35 : 30,
                                        key: ValueKey(candidateData.isNotEmpty),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      candidateData.isNotEmpty
                                          ? "Release to Delete 🗑️"
                                          : "Drag here to Delete",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            candidateData.isNotEmpty ? 17 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onWillAccept: (data) => data is Task,
                          onAccept: (Task task) {
                            Get.defaultDialog(
                              title: "Delete Task",
                              titleStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              middleText:
                                  "Are you sure you want to delete '${task.title}'?",
                              textConfirm: "Delete",
                              textCancel: "Cancel",
                              confirmTextColor: Colors.white,
                              cancelTextColor: Colors.grey[600],
                              buttonColor: Colors.red,
                              backgroundColor: Colors.white,
                              radius: 15,
                              onConfirm: () {
                                controller.deleteTask(task);
                                EasyLoading.showSuccess(
                                    'Task deleted successfully');
                                Get.back();
                              },
                            );
                            controller.changeDeleting(false);
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        // Enhanced FloatingActionButton
        floatingActionButton: Obx(
          () => controller.deleting.value
              ? const SizedBox.shrink()
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      if (controller.tasks.isNotEmpty) {
                        Get.to(() => AddDialog(),
                            transition: Transition.downToUp);
                      } else {
                        EasyLoading.showInfo("Please create your task type");
                      }
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // Enhanced Bottom Navigation Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 12.0,
            color: Colors.transparent,
            elevation: 0,
            child: Container(
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: 8.0.wp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Home Button
                  _buildNavButton(
                    icon: Icons.home_rounded,
                    label: "Home",
                    isActive: true,
                    onTap: () {
                      Get.offAll(() => HomePage());
                    },
                  ),

                  // Report Button
                  _buildNavButton(
                    icon: Icons.analytics_rounded,
                    label: "Reports",
                    isActive: false,
                    onTap: () {
                      Get.to(() => ReportPage());
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.0.wp, vertical: 2.0.wp),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.blue.shade600 : Colors.grey.shade600,
              size: 26,
            ),
            SizedBox(height: 1.0.wp),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.blue.shade600 : Colors.grey.shade600,
                fontSize: 12.0.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
