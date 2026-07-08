import 'package:get/get.dart';

import '../controllers/questions_list_controller.dart';

class QuestionsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionsListController>(
      () => QuestionsListController(),
    );
  }
}
