import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/app/core/values/colors.dart';
import 'package:getx_todolist/modules/home/controller.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

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
            var completedTasks = homeCtrl.getTotalDoneTask();
            var liveTasks = createdTasks - completedTasks;
            var percent = (createdTasks == 0)
                ? 0.0
                : (completedTasks / createdTasks * 100);

            return Padding(
              padding: EdgeInsets.only(bottom: 2.0.wp),
              child: Column(
                children: [
                  // Header Section
                  Padding(
                    padding: EdgeInsets.all(4.0.wp),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Get.back(),
                        ),
                        SizedBox(width: 2.0.wp),
                        Text(
                          'My Report',
                          style: TextStyle(
                            fontSize: 24.0.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Date Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0.wp),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat.yMMMMd().format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 14.0.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  Divider(
                    thickness: 1,
                    color: Colors.grey[300],
                    indent: 4.0.wp,
                    endIndent: 4.0.wp,
                  ),

                  // Stats Cards Section
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0.wp),
                    child: SizedBox(
                      height: 22.0.wp,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 4.0.wp),
                        children: [
                          _buildStatCard(
                            'Live Tasks',
                            liveTasks.toString(),
                            Colors.green,
                            Icons.access_time_filled,
                          ),
                          SizedBox(width: 4.0.wp),
                          _buildStatCard(
                            'Created',
                            createdTasks.toString(),
                            Colors.blue,
                            Icons.add_task,
                          ),
                          SizedBox(width: 4.0.wp),
                          _buildStatCard(
                            'Completed',
                            completedTasks.toString(),
                            Colors.orange,
                            Icons.check_circle,
                          ),
                          SizedBox(width: 4.0.wp),
                          _buildStatCard(
                            'Progress',
                            '${percent.toStringAsFixed(1)}%',
                            Colors.purple,
                            Icons.trending_up,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Progress Circle Section
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Your Progress',
                          style: TextStyle(
                            fontSize: 18.0.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4.0.wp),
                        UnconstrainedBox(
                          child: SizedBox(
                            width: 70.0.wp,
                            height: 70.0.wp,
                            child: CircularStepProgressIndicator(
                              totalSteps: createdTasks == 0 ? 1 : createdTasks,
                              currentStep: completedTasks,
                              stepSize: 20,
                              selectedColor: green,
                              unselectedColor: Colors.grey[200],
                              padding: 0,
                              width: 150,
                              height: 150,
                              selectedStepSize: 22,
                              roundedCap: (_, __) => true,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${percent.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.0.sp,
                                      color: green,
                                    ),
                                  ),
                                  SizedBox(height: 1.0.wp),
                                  Text(
                                    'Efficiency',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.0.sp, // Reduced from 12.0
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6.0.wp),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0.wp),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(green),
                            minHeight: 8.0,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: 2.0.wp),
                        Text(
                          '${completedTasks} out of ${createdTasks} tasks completed',
                          style: TextStyle(
                            fontSize: 12.0.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      width: 32.0.wp, // Increased from 30.0.wp
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: EdgeInsets.all(3.0.wp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.0.sp, color: color),
              SizedBox(width: 2.0.wp),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.0.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.0.wp),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.0.sp, // Reduced from 16.0.sp
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
