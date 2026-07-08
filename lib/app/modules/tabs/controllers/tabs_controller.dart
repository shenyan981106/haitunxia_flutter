import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/exam_repository.dart';
import '../../../services/global_project_controller.dart';
import '../../study/controllers/study_controller.dart';
import '../../study/views/study_view.dart';
import '../../home/views/home_view.dart';
import '../../questions/questionsHome/views/questions_home_view.dart';
import '../../user/views/user_view.dart';

class TabsController extends GetxController with WidgetsBindingObserver {
  // ==================== 页面控制 ====================

  RxInt currentIndex = 0.obs;
  PageController pageController = PageController(initialPage: 1);

  final List<Widget> pages = const [
    HomeView(),
    StudyView(),
    QuestionsHomeView(),
    UserView(),
  ];

  // ==================== 依赖注入 ====================

  late final ExamRepository _examRepository;
  late final GlobalProjectController _globalProjectController;

  // ==================== 项目数据 ====================

  /// 项目列表（从全局控制器获取）
  List<Project> get projects =>
      _globalProjectController.currentProject.value != null
          ? [_globalProjectController.currentProject.value!]
          : [];

  /// 当前选中项目
  Project? get currentProject => _globalProjectController.currentProject.value;

  // ==================== 科目数据 ====================

  /// 科目列表（从API获取）
  RxList<Subject> subjects = <Subject>[].obs;

  /// 当前选中科目索引
  RxInt currentSubjectIndex = 0.obs;

  /// 当前选中科目
  Subject? get currentSubject =>
      subjects.isNotEmpty && currentSubjectIndex.value < subjects.length
          ? subjects[currentSubjectIndex.value]
          : null;

  // ==================== 加载状态 ====================

  RxBool isLoadingSubjects = false.obs;
  RxString errorMessage = ''.obs;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _examRepository = Get.find<ExamRepository>();
    _globalProjectController = Get.find<GlobalProjectController>();

    // 监听全局项目变化，自动加载对应科目
    ever(_globalProjectController.currentProject, (_) {
      loadSubjects();
    });

    // 初始加载科目
    loadSubjects();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && currentIndex.value == 1) {
      _refreshStudyCourses();
    }
  }

  // ==================== 公开方法 ====================

  /// 设置底部导航当前索引
  void setCurrentIndex(int index) {
    currentIndex.value = index;
    if (index == 1) {
      _refreshStudyCourses(force: true);
    }
  }

  void _refreshStudyCourses({bool force = false}) {
    if (Get.isRegistered<StudyController>()) {
      Get.find<StudyController>().refreshWhenVisible(force: force);
    }
  }

  /// 设置当前选中科目
  void setCurrentSubjectIndex(int index) {
    if (index >= 0 && index < subjects.length) {
      currentSubjectIndex.value = index;
      // 同步更新全局控制器中的当前科目
      _globalProjectController.setCurrentSubject(subjects[index].name);
    }
  }

  /// 加载科目列表
  Future<void> loadSubjects() async {
    final project = _globalProjectController.currentProject.value;
    if (project == null) return;

    isLoadingSubjects.value = true;
    errorMessage.value = '';

    try {
      final response = await _examRepository.getSubjects(project.id);

      if (response.isSuccess && response.data != null) {
        // 转换 API 返回的 SubjectInfo 到 Subject 模型
        final subjectList = response.data!
            .map((info) => Subject(
                  id: info.id,
                  projectId: project.id,
                  name: info.name,
                  description: info.description ?? '',
                  icon: '',
                  questionCount: info.questionCount ?? 0,
                ))
            .toList();

        subjects.value = subjectList;

        // 重置选中索引
        if (subjectList.isNotEmpty) {
          currentSubjectIndex.value = 0;
          _globalProjectController.setCurrentSubject(subjectList[0].name);
        }
      } else {
        errorMessage.value = response.message;
        // API 失败时使用默认科目数据
        _loadDefaultSubjects(project.id);
      }
    } catch (e) {
      errorMessage.value = '加载科目失败: $e';
      // 出错时使用默认科目数据
      _loadDefaultSubjects(project.id);
    } finally {
      isLoadingSubjects.value = false;
    }
  }

  /// 加载默认科目数据（作为降级方案）
  void _loadDefaultSubjects(String projectId) {
    // 从配置文件或本地存储加载默认科目
    // 这里暂时使用空列表，实际项目中可以从本地 JSON 文件加载
    subjects.value = [];
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadSubjects();
  }
}
