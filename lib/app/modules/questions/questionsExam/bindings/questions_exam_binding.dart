import 'package:get/get.dart';
import '../controllers/questions_exam_controller.dart';

class QuestionsExamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionsExamController>(
      () => QuestionsExamController(
          pageType: Get.parameters['pageType'] ?? 'must_brush'),
    );
  }
}
