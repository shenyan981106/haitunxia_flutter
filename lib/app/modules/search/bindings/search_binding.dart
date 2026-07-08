import 'package:get/get.dart';

import '../controllers/question_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionSearchController>(
      () => QuestionSearchController(),
    );
  }
}
