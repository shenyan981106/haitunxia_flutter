import 'package:get/get.dart';
import '../controllers/questions_elist_controller.dart';

class QuestionsElistBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<QuestionsElistController>(
      QuestionsElistController(),
    );
  }
}
