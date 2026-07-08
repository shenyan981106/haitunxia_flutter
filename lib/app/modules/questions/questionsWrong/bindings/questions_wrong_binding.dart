import 'package:get/get.dart';

import '../controllers/questions_wrong_controller.dart';

class QuestionsWrongBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionsWrongController>(
      () => QuestionsWrongController(),
    );
  }
}
