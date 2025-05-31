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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _clearPreviousState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeCtrl.editCtrl.clear();
      homeCtrl.changeTask(null);
    });
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    // Validate form
    if (!homeCtrl.formKey.currentState!.validate()) {
      _showValidationError();
      return;
    }

    // Check if task is selected
    if (homeCtrl.task.value == null) {
      _showTaskSelectionError();
      return;
    }

    // Check if todo title is valid
    if (!homeCtrl.isValidTodoTitle(homeCtrl.editCtrl.text)) {
      _showInvalidTitleError();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Add haptic feedback
      HapticFeedback.lightImpact();

      final success = homeCtrl.updateTask(
        homeCtrl.task.value!,
        homeCtrl.editCtrl.text.trim(),
      );

      if (success) {
        await EasyLoading.showSuccess(
          'Todo item added successfully!',
          duration: const Duration(seconds: 1),
        );
        _handleSuccess();
      } else {
        await EasyLoading.showError(
          'Todo item already exists',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      await EasyLoading.showError(
        'Failed to add todo item',
        duration: const Duration(seconds: 2),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showValidationError() {
    HapticFeedback.selectionClick();
    EasyLoading.showError(
      'Please enter a valid todo title',
      duration: const Duration(seconds: 2),
    );
  }

  void _showTaskSelectionError() {
    HapticFeedback.selectionClick();
    EasyLoading.showError(
      'Please select a task category',
      duration: const Duration(seconds: 2),
    );
  }

  void _showInvalidTitleError() {
    HapticFeedback.selectionClick();
    EasyLoading.showError(
      'Todo title must be between 1-100 characters',
      duration: const Duration(seconds: 2),
    );
  }

  void _handleSuccess() {
    homeCtrl.editCtrl.clear();
    homeCtrl.changeTask(null);
    Get.back();
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    homeCtrl.editCtrl.clear();
    homeCtrl.changeTask(null);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: _isLoading ? null : _handleCancel,
        icon: const Icon(
          Icons.close,
          color: Colors.black87,
        ),
        tooltip: 'Cancel',
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 3.0.wp),
          child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                )
              : TextButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.0.wp,
                      vertical: 1.0.wp,
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
    return Padding(
      padding: EdgeInsets.all(5.0.wp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Todo',
            style: TextStyle(
              fontSize: 24.0.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.0.wp),
          Text(
            'Create a new todo item and assign it to a task category',
            style: TextStyle(
              fontSize: 12.0.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0.wp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todo Title',
            style: TextStyle(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.0.wp),
          TextFormField(
            controller: homeCtrl.editCtrl,
            enabled: !_isLoading,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Enter your todo item...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 12.0.sp,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              prefixIcon: Icon(
                Icons.edit_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              counterStyle: TextStyle(
                fontSize: 10.0.sp,
                color: Colors.grey[500],
              ),
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a todo title';
              }
              if (value.trim().length > 100) {
                return 'Todo title must be less than 100 characters';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSelector() {
    return Padding(
      padding: EdgeInsets.only(
        top: 5.0.wp,
        left: 5.0.wp,
        right: 5.0.wp,
        bottom: 2.0.wp,
      ),
      child: Row(
        children: [
          Icon(
            Icons.category_outlined,
            size: 16,
            color: Colors.grey[600],
          ),
          SizedBox(width: 2.0.wp),
          Text(
            'Select Task Category',
            style: TextStyle(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Obx(
            () => homeCtrl.task.value != null
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.0.wp,
                      vertical: 1.0.wp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 10.0.sp,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.0.wp,
                      vertical: 1.0.wp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 10.0.sp,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: Obx(() {
        if (homeCtrl.tasks.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 3.0.wp),
          itemCount: homeCtrl.tasks.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey[200],
          ),
          itemBuilder: (context, index) {
            final task = homeCtrl.tasks[index];
            final isSelected = homeCtrl.task.value == task;
            final taskColor = HexColor.fromHex(task.color);
            final completedTodos = homeCtrl.getDoneTodo(task);
            final totalTodos = homeCtrl.getTotalTodos(task);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? taskColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: _isLoading
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        homeCtrl.changeTask(task);
                      },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.0.wp,
                    vertical: 3.0.wp,
                  ),
                  child: Row(
                    children: [
                      // Task icon
                      Container(
                        padding: EdgeInsets.all(2.0.wp),
                        decoration: BoxDecoration(
                          color: taskColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          IconData(task.icon, fontFamily: 'MaterialIcons'),
                          color: taskColor,
                          size: 16,
                        ),
                      ),

                      SizedBox(width: 3.0.wp),

                      // Task details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? taskColor : Colors.black87,
                              ),
                            ),
                            if (totalTodos > 0) ...[
                              SizedBox(height: 1.0.wp),
                              Text(
                                '$completedTodos/$totalTodos todos completed',
                                style: TextStyle(
                                  fontSize: 10.0.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Selection indicator
                      AnimatedScale(
                        scale: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: EdgeInsets.all(1.0.wp),
                          decoration: BoxDecoration(
                            color: taskColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.0.wp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 4.0.wp),
            Text(
              'No Task Categories',
              style: TextStyle(
                fontSize: 16.0.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2.0.wp),
            Text(
              'Create a task category first before adding todos',
              style: TextStyle(
                fontSize: 12.0.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
