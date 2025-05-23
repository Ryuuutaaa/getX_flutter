import 'package:get/get.dart';
import 'package:getx_todolist/app/data/providers/task/provider.dart';
import 'package:getx_todolist/app/data/services/storage/repository.dart';
import 'package:getx_todolist/modules/home/controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => HomeController(
        taskRepository: TaskRepository(
          taskProvider: TaskProvider(),
        ),
      ),
    );
  }
}
