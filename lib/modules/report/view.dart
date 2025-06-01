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

            // Handle pembagian dengan nol
            var percent =
                createdTasks == 0 ? 0.0 : (completedTasks / createdTasks) * 100;

            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.0.wp),
                  child: Text(
                    'My Report',
                    style: TextStyle(
                      fontSize: 24.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0.wp),
                  child: Text(
                    DateFormat.yMMMd().format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14.0.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.0.wp,
                    vertical: 4.0.wp,
                  ),
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.0.wp,
                    vertical: 4.0.wp,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatus(
                          Colors.green,
                          liveTasks,
                          'Live Tasks',
                        ),
                        SizedBox(width: 4.0.wp),
                        _buildStatus(
                          Colors.blue,
                          createdTasks,
                          'Created Tasks',
                        ),
                        SizedBox(width: 4.0.wp),
                        _buildStatus(
                          Colors.orange,
                          completedTasks,
                          'Completed Tasks',
                        ),
                        SizedBox(width: 4.0.wp),
                        _buildStatus(
                          Colors.purple,
                          percent.round(),
                          'Percent',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0.wp,
                ),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '${createdTasks == 0 ? 1 : percent}% ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0.sp,
                            ),
                          ),
                          SizedBox(
                            height: 1.0.wp,
                          ),
                          Text(
                            'Efficiency',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0.sp),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatus(Color color, int number, String text) {
    return Container(
      constraints: BoxConstraints(minWidth: 20.0.wp),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3.0.wp,
            width: 3.0.wp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 0.5.wp,
                color: color,
              ),
            ),
          ),
          SizedBox(
            width: 2.0.wp,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0.sp,
                  ),
                ),
                SizedBox(
                  height: 2.0.wp,
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.0.sp,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
