import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/modules/home/controller.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog>
    with SingleTickerProviderStateMixin {
  final homeCtrl = Get.find<HomeController>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _clearPreviousState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  void _clearPreviousState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeCtrl.editCtrl.clear();
      homeCtrl.changeTask(null);
    });
  }

  // ... [Keep all your existing methods like _handleSubmit, _showValidationError, etc.] ...

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) return false;
        _handleCancel();
        return false;
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: _buildAppBar(),
                body: _buildBody(),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: _isLoading ? null : _handleCancel,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[100],
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Colors.black87,
            size: 20,
          ),
        ),
        tooltip: 'Cancel',
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 5.0.wp),
          child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                )
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translate(0.0, _isLoading ? 10.0 : 0.0, 0.0),
                  child: ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      elevation: 1,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.0.wp,
                        vertical: 1.5.wp,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Form(
      key: homeCtrl.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildInputField(),
          _buildTaskSelector(),
          _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.all(6.0.wp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Todo',
              style: TextStyle(
                fontSize: 26.0.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            SizedBox(height: 1.0.wp),
            Text(
              'Create a new todo and organize it in your workflow',
              style: TextStyle(
                fontSize: 12.0.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.0.wp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TITLE',
              style: TextStyle(
                fontSize: 11.0.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2.0.wp),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: homeCtrl.editCtrl,
                enabled: !_isLoading,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.0.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 60),
                  counterStyle: TextStyle(
                    fontSize: 10.0.sp,
                    color: Colors.grey[500],
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 3.0.wp, horizontal: 4.0.wp),
                ),
                style: TextStyle(
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w500,
                ),
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a todo title';
                  }
                  if (value.trim().length > 100) {
                    return 'Title must be ≤100 characters';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSelector() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.only(
          top: 6.0.wp,
          left: 6.0.wp,
          right: 6.0.wp,
          bottom: 3.0.wp,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_rounded,
                size: 18,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 3.0.wp),
            Text(
              'TASK CATEGORY',
              style: TextStyle(
                fontSize: 11.0.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            Obx(
              () => homeCtrl.task.value != null
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.0.wp,
                        vertical: 1.2.wp,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          SizedBox(width: 1.5.wp),
                          Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 10.0.sp,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.0.wp,
                        vertical: 1.2.wp,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: Colors.orange[700],
                          ),
                          SizedBox(width: 1.5.wp),
                          Text(
                            'Required',
                            style: TextStyle(
                              fontSize: 10.0.sp,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Obx(() {
      if (homeCtrl.tasks.isEmpty) {
        return _buildEmptyState();
      }

      return SlideTransition(
        position: _slideAnimation,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 6.0.wp),
          itemCount: homeCtrl.tasks.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey[100],
            indent: 12.0.wp,
          ),
          itemBuilder: (context, index) {
            final task = homeCtrl.tasks[index];
            final isSelected = homeCtrl.task.value == task;
            final taskColor = HexColor.fromHex(task.color);
            final completedTodos = homeCtrl.getDoneTodo(task);
            final totalTodos = homeCtrl.getTotalTodos(task);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(bottom: 2.0.wp),
              decoration: BoxDecoration(
                color: isSelected
                    ? taskColor.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: taskColor.withOpacity(0.3), width: 1.5)
                    : null,
              ),
              child: InkWell(
                onTap: _isLoading
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        homeCtrl.changeTask(task);
                      },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.0.wp,
                    vertical: 4.0.wp,
                  ),
                  child: Row(
                    children: [
                      // Task icon with animated background
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(3.0.wp),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? taskColor.withOpacity(0.2)
                              : taskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconData(task.icon, fontFamily: 'MaterialIcons'),
                          color: isSelected
                              ? taskColor
                              : taskColor.withOpacity(0.9),
                          size: 18,
                        ),
                      ),

                      SizedBox(width: 4.0.wp),

                      // Task details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? taskColor : Colors.black87,
                              ),
                            ),
                            if (totalTodos > 0) ...[
                              SizedBox(height: 1.0.wp),
                              LinearProgressIndicator(
                                value: completedTodos / totalTodos,
                                backgroundColor: Colors.grey[200],
                                color: taskColor,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              SizedBox(height: 1.0.wp),
                              Text(
                                '$completedTodos of $totalTodos completed',
                                style: TextStyle(
                                  fontSize: 10.0.sp,
                                  color: isSelected
                                      ? taskColor.withOpacity(0.7)
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Selection indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? taskColor.withOpacity(0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? taskColor : Colors.grey[300]!,
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: taskColor,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return SlideTransition(
      position: _slideAnimation,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0.wp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.0.wp),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 6.0.wp),
              Text(
                'No Task Categories',
                style: TextStyle(
                  fontSize: 18.0.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 2.0.wp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0.wp),
                child: Text(
                  'Create a task category first to organize your todos effectively',
                  style: TextStyle(
                    fontSize: 12.0.sp,
                    color: Colors.grey[500],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 4.0.wp),
              OutlinedButton.icon(
                onPressed: () {
                  // Add navigation to create task category
                  Get.back();
                },
                icon: Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: Colors.blue,
                ),
                label: Text(
                  'Create Task Category',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                  padding: EdgeInsets.symmetric(
                      horizontal: 5.0.wp, vertical: 2.5.wp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
