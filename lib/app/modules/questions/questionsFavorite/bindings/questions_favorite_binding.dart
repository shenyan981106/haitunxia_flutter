import 'package:get/get.dart';

import '../controllers/questions_favorite_controller.dart';

class QuestionsFavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionsFavoriteController>(
      () => QuestionsFavoriteController(),
    );
  }
}
