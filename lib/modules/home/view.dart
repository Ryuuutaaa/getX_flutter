import 'dart:ui';

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
import 'dart:math';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Background with subtle gradient and animated bubbles
            _buildAnimatedBackground(),

            // Main content
            Column(
              children: [
                // Header Section
                _buildHeader(),

                // Tasks Grid
                Expanded(
                  child: _buildTaskGrid(),
                ),
              ],
            ),

            // Drag to delete area
            _buildDeleteArea(),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50.withOpacity(0.8),
                Colors.grey.shade50.withOpacity(0.8),
              ],
              stops: const [0.0, 0.6],
            ),
          ),
        ),
        // Animated bubbles
        Positioned(
          top: 10.0.wp,
          left: 20.0.wp,
          child: _buildAnimatedBubble(
              Colors.blue.shade100.withOpacity(0.4), 15.0.wp),
        ),
        Positioned(
          bottom: 30.0.wp,
          right: 10.0.wp,
          child: _buildAnimatedBubble(
              Colors.blue.shade200.withOpacity(0.3), 20.0.wp),
        ),
        Positioned(
          top: 40.0.wp,
          right: 25.0.wp,
          child: _buildAnimatedBubble(
              Colors.blue.shade100.withOpacity(0.2), 12.0.wp),
        ),
      ],
    );
  }

  Widget _buildAnimatedBubble(Color color, double size) {
    return StatefulBuilder(
      builder: (context, setState) {
        final controller = AnimationController(
          duration: const Duration(seconds: 10),
          vsync: Scaffold.of(context),
        )..repeat(); // This makes the animation repeat indefinitely

        final animation =
            Tween<double>(begin: 0.0, end: 2 * pi).animate(controller);

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + 0.1 * sin(animation.value),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(6.0.wp),
      margin: EdgeInsets.symmetric(horizontal: 4.0.wp, vertical: 2.0.wp),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
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
          Obx(() => _buildTaskCountBadge(controller.tasks.length)),
        ],
      ),
    );
  }

  Widget _buildTaskCountBadge(int count) {
    return Container(
      padding: EdgeInsets.all(3.0.wp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        "$count",
        style: TextStyle(
          fontSize: 18.0.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTaskGrid() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0.wp),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 4.0.wp,
          mainAxisSpacing: 4.0.wp,
          physics: const ClampingScrollPhysics(),
          childAspectRatio: 0.85,
          children: [
            ...controller.tasks.map(
              (task) => LongPressDraggable<Task>(
                data: task,
                onDragStarted: () => controller.changeDeleting(true),
                onDraggableCanceled: (_, __) =>
                    controller.changeDeleting(false),
                onDragEnd: (_) => controller.changeDeleting(false),
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
                              color: Colors.black.withOpacity(0.2),
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
      );
    });
  }

  Widget _buildDeleteArea() {
    return Obx(() {
      return controller.deleting.value
          ? Positioned(
              bottom: 100,
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
                            ? [Colors.red.shade600, Colors.red.shade400]
                            : [Colors.red.shade400, Colors.red.shade300],
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
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              candidateData.isNotEmpty
                                  ? Icons.delete_forever
                                  : Icons.delete_outline,
                              color: Colors.white,
                              size: candidateData.isNotEmpty ? 35 : 30,
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
                              fontSize: candidateData.isNotEmpty ? 17 : 16,
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
                      EasyLoading.showSuccess('Task deleted successfully');
                      Get.back();
                    },
                  );
                  controller.changeDeleting(false);
                },
              ),
            )
          : const SizedBox.shrink();
    });
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      return controller.deleting.value
          ? const SizedBox.shrink()
          : TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: FloatingActionButton(
                onPressed: () {
                  if (controller.tasks.isNotEmpty) {
                    Get.to(() => AddDialog(),
                        transition: Transition.downToUp,
                        duration: const Duration(milliseconds: 300));
                  } else {
                    EasyLoading.showInfo("Please create your task type");
                  }
                },
                backgroundColor: Colors.blue.shade600,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            );
    });
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavButton(
                  icon: Icons.home_rounded,
                  label: "Home",
                  isActive: true,
                  onTap: () {
                    Get.offAll(() => HomePage());
                  },
                ),
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
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 6.0.wp, vertical: 2.0.wp),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.shade50.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
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
