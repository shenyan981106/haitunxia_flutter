import 'package:get/get.dart';

import '../modules/splash/views/splash_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/views/verification_view.dart';
import '../modules/user/views/feedback_view.dart';
import '../modules/user/views/question_feedback_view.dart';
import '../modules/user/views/complaint_feedback_view.dart';
import '../modules/user/bindings/complaint_feedback_binding.dart';
import '../modules/user/views/enterprise_agreement_view.dart';
import '../modules/user/views/platform_qualification_view.dart';
import '../modules/user/views/my_courses_view.dart';
import '../modules/user/views/my_orders_view.dart';
import '../modules/user/views/order_detail_view.dart';
import '../modules/user/views/my_favorites_view.dart';
import '../modules/user/views/feedback_records_view.dart';
import '../modules/user/views/feedback_record_detail_view.dart';
import '../modules/user/bindings/my_courses_binding.dart';
import '../modules/user/bindings/my_orders_binding.dart';
import '../modules/user/bindings/order_detail_binding.dart';
import '../modules/user/bindings/my_favorites_binding.dart';
import '../modules/user/views/modify_nickname_view.dart';
import '../modules/user/views/delete_account_view.dart';
import '../modules/user/views/vip_center_view.dart';
import '../modules/user/bindings/modify_nickname_binding.dart';
import '../modules/user/bindings/delete_account_binding.dart';
import '../modules/user/bindings/vip_center_binding.dart';
import '../modules/user/bindings/question_feedback_binding.dart';

// 其他导入保持不变
import '../modules/project/bindings/project_binding.dart';
import '../modules/project/views/project_view.dart';
import '../modules/questions/questionTrain/bindings/question_train_binding.dart';
import '../modules/questions/questionTrain/views/question_train_view.dart';
import '../modules/questions/questionsHome/bindings/questions_home_binding.dart';
import '../modules/questions/questionsHome/views/questions_home_view.dart';
import '../modules/questions/questionsList/bindings/questions_list_binding.dart';
import '../modules/questions/questionsList/views/questions_list_view.dart';
import '../modules/questions/questionsResult/bindings/questions_result_binding.dart';
import '../modules/questions/questionsResult/views/questions_result_view.dart';
import '../modules/questions/questionsExam/bindings/questions_exam_binding.dart';
import '../modules/questions/questionsExam/views/questions_exam_view.dart';
import '../modules/questions/questionsElist/bindings/questions_elist_binding.dart';
import '../modules/questions/questionsElist/views/questions_elist_view.dart';
import '../modules/questions/questionsFavorite/bindings/questions_favorite_binding.dart';
import '../modules/questions/questionsFavorite/views/questions_favorite_view.dart';
import '../modules/questions/questionsWrong/bindings/questions_wrong_binding.dart';
import '../modules/questions/questionsWrong/views/questions_wrong_view.dart';
import '../modules/study/bindings/study_binding.dart';
import '../modules/study/bindings/details_binding.dart';
import '../modules/study/views/study_view.dart';
import '../modules/study/views/details_view.dart';
import '../modules/study/views/order_confirm_view.dart';
import '../modules/study/bindings/video_player_binding.dart';
import '../modules/study/views/video_player_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/tabs/bindings/tabs_binding.dart';
import '../modules/tabs/views/tabs_view.dart';
import '../modules/my_bank/bindings/my_bank_binding.dart';
import '../modules/my_bank/views/my_bank_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
    ),
    GetPage(
      name: _Paths.TABS,
      page: () => const TabsView(),
      binding: TabsBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.QUESTIONS_LIST,
      page: () => const QuestionsListView(),
      binding: QuestionsListBinding(),
    ),
    GetPage(
      name: _Paths.QUESTION_TRAIN,
      page: () => const QuestionTrainView(),
      binding: QuestionTrainBinding(),
    ),
    GetPage(
      name: _Paths.QUESTIONS_RESULT,
      page: () => const QuestionsResultView(),
      binding: QuestionsResultBinding(),
    ),
    GetPage(
      name: _Paths.QUESTIONS_HOME,
      page: () => const QuestionsHomeView(),
      binding: QuestionsHomeBinding(),
    ),
    GetPage(
      name: _Paths.QUESTIONS + _Paths.QUESTIONS_EXAM,
      page: () => const QuestionsExamView(),
      binding: QuestionsExamBinding(),
    ),
    GetPage(
      name: _Paths.QUESTIONS + _Paths.QUESTIONS_ELIST,
      page: () => const QuestionsElistView(),
      binding: QuestionsElistBinding(),
    ),
    GetPage(
      name: _Paths.QUESTIONS + _Paths.QUESTIONS_FAVORITE,
      page: () => const QuestionsFavoriteView(),
      binding: QuestionsFavoriteBinding(),
    ),
    GetPage(
      name: _Paths.QUESTIONS + _Paths.QUESTIONS_WRONG,
      page: () => const QuestionsWrongView(),
      binding: QuestionsWrongBinding(),
    ),
    GetPage(
      name: _Paths.STUDY,
      page: () => const StudyView(),
      binding: StudyBinding(),
    ),
    GetPage(
      name: _Paths.STUDY + '/details',
      page: () => const DetailsView(),
      binding: DetailsBinding(),
    ),
    GetPage(
      name: _Paths.STUDY + '/order-confirm',
      page: () {
        final args = Get.arguments;
        return OrderConfirmView(
            courseData: args is Map<String, dynamic> ? args : {});
      },
    ),
    GetPage(
      name: _Paths.STUDY + '/video-player',
      page: () => const VideoPlayerView(),
      binding: VideoPlayerBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROJECT,
      page: () => ProjectView(),
      binding: ProjectBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.VERIFICATION,
      page: () => VerificationView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.FEEDBACK,
      page: () => const FeedbackView(),
    ),
    GetPage(
      name: _Paths.COMPLAINT_FEEDBACK,
      page: () => const ComplaintFeedbackView(),
      binding: ComplaintFeedbackBinding(),
    ),
    GetPage(
      name: _Paths.MY_BANK,
      page: () => const MyBankView(),
      binding: MyBankBinding(),
    ),
    GetPage(
      name: _Paths.ENTERPRISE_AGREEMENT,
      page: () => const EnterpriseAgreementView(),
    ),
    GetPage(
      name: _Paths.PLATFORM_QUALIFICATION,
      page: () => const PlatformQualificationView(),
    ),
    GetPage(
      name: _Paths.MY_COURSES,
      page: () => const MyCoursesView(),
      binding: MyCoursesBinding(),
    ),
    GetPage(
      name: _Paths.MY_ORDERS,
      page: () => const MyOrdersView(),
      binding: MyOrdersBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAIL,
      page: () => const OrderDetailView(),
      binding: OrderDetailBinding(),
    ),
    GetPage(
      name: _Paths.MY_FAVORITES,
      page: () => const MyFavoritesView(),
      binding: MyFavoritesBinding(),
    ),
    GetPage(
      name: _Paths.FEEDBACK_RECORDS,
      page: () => const FeedbackRecordsView(),
    ),
    GetPage(
      name: _Paths.FEEDBACK_RECORD_DETAIL,
      page: () => const FeedbackRecordDetailView(),
    ),
    GetPage(
      name: _Paths.MODIFY_NICKNAME,
      page: () => const ModifyNicknameView(),
      binding: ModifyNicknameBinding(),
    ),
    GetPage(
      name: _Paths.DELETE_ACCOUNT,
      page: () => const DeleteAccountView(),
      binding: DeleteAccountBinding(),
    ),
    GetPage(
      name: _Paths.VIP_CENTER,
      page: () => const VipCenterView(),
      binding: VipCenterBinding(),
    ),
    GetPage(
      name: _Paths.QUESTION_FEEDBACK,
      page: () => const QuestionFeedbackView(),
      binding: QuestionFeedbackBinding(),
    ),
  ];
}
