import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/modules/home/controller.dart';

class DoneList extends StatelessWidget {
  final HomeController homeCtrl = Get.find<HomeController>();

  DoneList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (homeCtrl.doneTodos.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompletedHeader(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: _buildDoneTodosList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCompletedHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 5.0.wp,
        vertical: 2.0.wp,
      ),
      child: Row(
        children: [
          Text(
            'Completed',
            style: TextStyle(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 2.0.wp),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 3.0.wp,
              vertical: 0.5.wp,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${homeCtrl.doneTodos.length}',
              style: TextStyle(
                fontSize: 11.0.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDoneTodosList() {
    return homeCtrl.doneTodos.map((todo) => _buildDoneTodoItem(todo)).toList();
  }

  Widget _buildDoneTodoItem(Map<String, dynamic> todo) {
    // Use a stable key based only on todo's unique identifier
    final uniqueKey = Key('dismissible_${todo['id'] ?? todo['title']}');

    return Dismissible(
      key: uniqueKey,
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation();
        } else if (direction == DismissDirection.startToEnd) {
          homeCtrl.uncompleteTodo(todo);
          return false; // Return false since we already handled the action
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          homeCtrl.deleteDoneTodo(todo);
        }
      },
      background: _buildRestoreBackground(),
      secondaryBackground: _buildDismissibleBackground(),
      child: InkWell(
        onTap: () => _showTodoOptions(todo),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4.0.wp,
            vertical: 3.0.wp,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildDoneIcon(),
              SizedBox(width: 4.0.wp),
              _buildDoneTodoText(todo),
              const Spacer(),
              _buildMoreButton(todo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(Map<String, dynamic> todo) {
    return IconButton(
      icon: Icon(
        Icons.more_vert,
        size: 16.0.sp,
        color: Colors.grey[500],
      ),
      onPressed: () => _showTodoOptions(todo),
    );
  }

  void _showTodoOptions(Map<String, dynamic> todo) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(5.0.wp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.undo),
              title: const Text('Mark as incomplete'),
              onTap: () {
                Get.back();
                homeCtrl.uncompleteTodo(todo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Get.back();
                final shouldDelete = await _showDeleteConfirmation();
                if (shouldDelete) {
                  homeCtrl.deleteDoneTodo(todo);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 5.0.wp),
      margin: EdgeInsets.symmetric(horizontal: 2.0.wp, vertical: 1.0.wp),
      child: const Icon(
        Icons.delete_forever,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRestoreBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 5.0.wp),
      margin: EdgeInsets.symmetric(horizontal: 2.0.wp, vertical: 1.0.wp),
      child: const Icon(
        Icons.undo,
        color: Colors.white,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('This task will be permanently deleted.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ) ??
        false;
  }

  Widget _buildDoneIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Icon(
        Icons.check,
        size: 16,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildDoneTodoText(Map<String, dynamic> todo) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todo['title'] ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.0.sp,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[600],
            ),
          ),
          if (todo['note'] != null && todo['note'].toString().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 0.5.wp),
              child: Text(
                todo['note'],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.0.sp,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[400],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
