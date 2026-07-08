import 'package:get/get.dart';

import '../controllers/question_train_controller.dart';

class QuestionTrainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionTrainController>(
      () => QuestionTrainController(),
    );
  }
}