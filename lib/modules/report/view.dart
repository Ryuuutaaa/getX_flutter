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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          var createdTasks = homeCtrl.getTotalTask();
          var completedTasks = homeCtrl.getTotalDoneTask();
          var liveTasks = createdTasks - completedTasks;
          var percent =
              (createdTasks == 0) ? 0.0 : (completedTasks / createdTasks * 100);

          return Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.all(4.0.wp),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 22.0.sp),
                      onPressed: () => Get.back(),
                      color: Colors.grey[800],
                    ),
                    SizedBox(width: 2.0.wp),
                    Text(
                      'Task Report',
                      style: TextStyle(
                        fontSize: 20.0.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.all(2.0.wp),
                      decoration: BoxDecoration(
                        color: blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        size: 20.0.sp,
                        color: blue,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey[200]),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5.0.wp, vertical: 3.0.wp),
                  child: Column(
                    children: [
                      // Date and Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEE, MMM d').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 12.0.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${percent.toStringAsFixed(0)}% Completed',
                            style: TextStyle(
                              fontSize: 12.0.sp,
                              color: green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0.wp),

                      // Stats Cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 3.0.wp,
                        crossAxisSpacing: 3.0.wp,
                        children: [
                          _buildStatCard(
                            title: 'Live Tasks',
                            value: liveTasks.toString(),
                            color: Colors.green,
                            icon: Icons.access_time_outlined,
                          ),
                          _buildStatCard(
                            title: 'Created',
                            value: createdTasks.toString(),
                            color: Colors.blue,
                            icon: Icons.add_task_outlined,
                          ),
                          _buildStatCard(
                            title: 'Completed',
                            value: completedTasks.toString(),
                            color: Colors.orange,
                            icon: Icons.check_circle_outline,
                          ),
                          _buildStatCard(
                            title: 'Progress',
                            value: '${percent.toStringAsFixed(1)}%',
                            color: Colors.purple,
                            icon: Icons.trending_up_outlined,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0.wp),

                      // Progress Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5.0.wp),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PROGRESS OVERVIEW',
                              style: TextStyle(
                                fontSize: 12.0.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.0.wp),
                            Center(
                              child: SizedBox(
                                width: 65.0.wp,
                                height: 65.0.wp,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularStepProgressIndicator(
                                      totalSteps:
                                          createdTasks == 0 ? 1 : createdTasks,
                                      currentStep: completedTasks,
                                      stepSize: 20,
                                      selectedColor: green,
                                      unselectedColor: Colors.grey[200]!,
                                      padding: 0,
                                      width: double.infinity,
                                      height: double.infinity,
                                      selectedStepSize: 22,
                                      roundedCap: (_, __) => true,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${percent.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 24.0.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        Text(
                                          'Efficiency',
                                          style: TextStyle(
                                            fontSize: 12.0.sp,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 4.0.wp),
                            LinearProgressIndicator(
                              value: percent / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(green),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            SizedBox(height: 2.0.wp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Completed: ',
                                  style: TextStyle(
                                    fontSize: 11.0.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '$completedTasks/$createdTasks',
                                  style: TextStyle(
                                    fontSize: 11.0.sp,
                                    color: green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.0.wp),

                      // Productivity Tip
                      if (percent < 70)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.0.wp),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orange[100]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.orange,
                                size: 18.0.sp,
                              ),
                              SizedBox(width: 3.0.wp),
                              Expanded(
                                child: Text(
                                  'Try focusing on high-priority tasks first to improve your efficiency',
                                  style: TextStyle(
                                    fontSize: 11.0.sp,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.0.wp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.wp),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 14.0.sp,
                    color: color,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.0.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 1.0.wp),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.0.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
