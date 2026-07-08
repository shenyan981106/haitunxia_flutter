import 'package:get/get.dart';
import '../controllers/tabs_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../user/controllers/user_controller.dart';
import '../../study/controllers/study_controller.dart';
import '../../questions/questionsHome/controllers/questions_home_controller.dart'
    as questions;

class TabsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TabsController>(
      () => TabsController(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<UserController>(
      () => UserController(),
    );
    Get.lazyPut<StudyController>(
      () => StudyController(),
    );
    Get.lazyPut<questions.QuestionsHomeController>(
      () => questions.QuestionsHomeController(),
    );
  }
}
