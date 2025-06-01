import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:getx_todolist/app/core/utils/extension.dart';
import 'package:getx_todolist/app/data/models/task.dart';
import 'package:getx_todolist/modules/detail/widget/doing_list.dart';
import 'package:getx_todolist/modules/detail/widget/done_list.dart';
import 'package:getx_todolist/modules/home/controller.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  final HomeController homeCtrl = Get.find();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _initializeState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeCtrl.editCtrl.clear();
    });
  }

  Future<void> _handleAddTodo() async {
    if (_isLoading) return;

    // Validate form
    if (!homeCtrl.formKey.currentState!.validate()) {
      HapticFeedback.selectionClick();
      return;
    }

    final todoText = homeCtrl.editCtrl.text.trim();

    if (!homeCtrl.isValidTodoTitle(todoText)) {
      HapticFeedback.selectionClick();
      EasyLoading.showError(
        'Todo title must be between 1-100 characters',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.lightImpact();

      final success = homeCtrl.addTodo(todoText);

      if (success) {
        await EasyLoading.showSuccess(
          'Todo added successfully!',
          duration: const Duration(seconds: 1),
        );
        homeCtrl.editCtrl.clear();
        await _saveChanges();
      } else {
        await EasyLoading.showError(
          'Todo already exists',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      await EasyLoading.showError(
        'Failed to add todo',
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

  Future<void> _saveChanges() async {
    try {
      homeCtrl.updateTodos();
      await EasyLoading.showSuccess('Changes saved!',
          duration: const Duration(seconds: 1));
    } on Exception catch (e) {
      debugPrint('Error saving todos: $e');
      await EasyLoading.showError('Failed to save changes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveChanges();
        return true;
      },
      child: Obx(() {
        final Task? task = homeCtrl.task.value;

        if (task == null) {
          return _buildErrorState();
        }

        return _buildDetailView(task);
      }),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 4.0.wp),
            Text(
              'No Task Selected',
              style: TextStyle(
                fontSize: 18.0.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2.0.wp),
            Text(
              'Please select a task to view details',
              style: TextStyle(
                fontSize: 12.0.sp,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 6.0.wp),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.0.wp,
                  vertical: 3.0.wp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(Task task) {
    final color = HexColor.fromHex(task.color);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              body: Form(
                key: homeCtrl.formKey,
                child: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(task, color),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildTaskHeader(task, color),
                          _buildProgressSection(color),
                          _buildAddTodoSection(),
                          _buildTodoLists(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(Task task, Color color) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: color,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () async {
          await _saveChanges();
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
      ),
      actions: [
        IconButton(
          onPressed: () => _showTaskInfo(task),
          icon: const Icon(Icons.info_outline),
          tooltip: 'Task Info',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(Task task, Color color) {
    return Container(
      margin: EdgeInsets.all(4.0.wp),
      padding: EdgeInsets.all(5.0.wp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.0.wp),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconData(task.icon, fontFamily: 'MaterialIcons'),
              color: color,
              size: 24,
            ),
          ),
          SizedBox(width: 4.0.wp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 1.0.wp),
                Obx(() {
                  final totalTodos =
                      homeCtrl.doingTodos.length + homeCtrl.doneTodos.length;
                  final completedTodos = homeCtrl.doneTodos.length;
                  final progress = totalTodos > 0
                      ? (completedTodos / totalTodos * 100).round()
                      : 0;

                  return Text(
                    '$completedTodos of $totalTodos todos completed ($progress%)',
                    style: TextStyle(
                      fontSize: 12.0.sp,
                      color: Colors.grey[600],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0.wp),
      padding: EdgeInsets.all(5.0.wp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: color,
                size: 20,
              ),
              SizedBox(width: 2.0.wp),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.0.wp),
          Obx(() {
            final totalTodos =
                homeCtrl.doingTodos.length + homeCtrl.doneTodos.length;
            final completedTodos = homeCtrl.doneTodos.length;

            if (totalTodos == 0) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'No todos yet',
                    style: TextStyle(
                      fontSize: 10.0.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                StepProgressIndicator(
                  totalSteps: totalTodos,
                  currentStep: completedTodos,
                  size: 8,
                  padding: 0,
                  selectedGradientColor: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [color.withOpacity(0.7), color],
                  ),
                  unselectedGradientColor: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.grey[300]!, Colors.grey[300]!],
                  ),
                  roundedEdges: const Radius.circular(4),
                ),
                SizedBox(height: 2.0.wp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedTodos completed',
                      style: TextStyle(
                        fontSize: 11.0.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${totalTodos - completedTodos} remaining',
                      style: TextStyle(
                        fontSize: 11.0.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddTodoSection() {
    return Container(
      margin: EdgeInsets.all(4.0.wp),
      padding: EdgeInsets.all(5.0.wp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_task,
                color: Colors.blue,
                size: 20,
              ),
              SizedBox(width: 2.0.wp),
              Text(
                'Add New Todo',
                style: TextStyle(
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.0.wp),
          TextFormField(
            controller: homeCtrl.editCtrl,
            enabled: !_isLoading,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
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
                Icons.check_box_outline_blank,
                color: Colors.grey[600],
                size: 20,
              ),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: _handleAddTodo,
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      tooltip: 'Add Todo',
                    ),
              counterStyle: TextStyle(
                fontSize: 10.0.sp,
                color: Colors.grey[500],
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a todo item';
              }
              if (value.trim().length > 100) {
                return 'Todo must be less than 100 characters';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleAddTodo(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoLists() {
    return Column(
      children: [
        DoingList(),
        SizedBox(height: 2.0.wp),
        DoneList(),
        SizedBox(height: 20.0.wp),
      ],
    );
  }

  void _showTaskInfo(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              IconData(task.icon, fontFamily: 'MaterialIcons'),
              color: HexColor.fromHex(task.color),
            ),
            SizedBox(width: 2.0.wp),
            Text(task.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final totalTodos =
                  homeCtrl.doingTodos.length + homeCtrl.doneTodos.length;
              final completedTodos = homeCtrl.doneTodos.length;
              final progress = totalTodos > 0
                  ? (completedTodos / totalTodos * 100).round()
                  : 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Todos: $totalTodos'),
                  Text('Completed: $completedTodos'),
                  Text('Remaining: ${totalTodos - completedTodos}'),
                  Text('Progress: $progress%'),
                ],
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
