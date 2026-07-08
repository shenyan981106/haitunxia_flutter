import 'package:get/get.dart';

import '../controllers/questions_result_controller.dart';

class QuestionsResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionsResultController>(
      () => QuestionsResultController(),
    );
  }
}
