import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xmshop/app/data/models/project_model.dart';
import 'package:xmshop/app/data/models/global_project_model.dart';
import 'package:xmshop/app/data/repositories/exam_repository.dart';
import 'package:xmshop/app/data/services/auth_service.dart';
import 'package:xmshop/app/routes/app_pages.dart';

/// 全局项目控制器
/// 管理当前选中的考试项目、科目、章节等全局状态
class GlobalProjectController extends GetxController {
  static GlobalProjectController get to => Get.find();

  /// 根据登录状态获取初始路由
  static String getInitialRoute() {
    return AuthService.to.checkLogin()
        ? AppPages.INITIAL // 已登录，首页
        : Routes.LOGIN; // 未登录，登录页
  }

  final GetStorage _storage = GetStorage();
  final String _storageKey = 'current_project';
  final String _storageModeKey = 'page_mode';

  /// Repository 实例
  late final ExamRepository _examRepository;

  // ==================== 响应式状态 ====================

  /// 当前选中的项目
  Rx<Project?> currentProject = Rx<Project?>(null);

  /// 当前页面模式：TRAINING(练习)、EXAM(考试)、VIEW(看题)
  RxString pageMode = 'TRAINING'.obs;

  /// 当前选中的科目名称
  RxString currentSubject = ''.obs;

  /// 当前选中的章节名称
  RxString currentChapter = ''.obs;

  /// 加载状态
  RxBool isLoading = false.obs;

  /// 考试倒计时数据
  Rx<GlobalExamCountdown?> examCountdown = Rx<GlobalExamCountdown?>(null);

  /// 错误信息
  RxString errorMessage = ''.obs;

  /// 距离考试天数
  RxInt daysToExam = 200.obs;

  /// 考试倒计时文本
  RxString examCountdownText = ''.obs;

  // ==================== 计算属性 ====================

  String get currentProjectName => currentProject.value?.name ?? '请选择考试项目';

  String get currentModeName {
    switch (pageMode.value) {
      case 'EXAM':
        return '考试模式';
      case 'VIEW':
        return '看题模式';
      case 'TRAINING':
      default:
        return '练习模式';
    }
  }

  // ==================== 公开方法 ====================

  /// 选择项目
  void selectProject(Project project) {
    currentProject.value = project;
    _storage.write(_storageKey, project.toJson());
    debugPrint('已切换项目 ${project.name}');
    printGlobalSettings();
    loadApiData();
  }

  /// 设置当前科目
  void setCurrentSubject(String subject) {
    currentSubject.value = subject;
    debugPrint('已设置科目 $subject');
  }

  /// 设置当前章节
  void setCurrentChapter(String chapter) {
    currentChapter.value = chapter;
    debugPrint('已设置章节 $chapter');
  }

  /// 设置页面模式
  void setPageMode(String mode) {
    pageMode.value = mode;
    _storage.write(_storageModeKey, mode);
    debugPrint('已切换模式 $mode');
    printGlobalSettings();
  }

  /// 加载公共接口数据
  Future<void> loadApiData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final examType = _resolveExamType();
      final response = await _examRepository.getCommonIndex(examType);
      debugPrint('getExamCountdown 响应: $response');
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        examCountdown.value = data.examCountdown;

        if (data.examCountdown != null) {
          final cd = data.examCountdown!;
          debugPrint('examCountdown 解析数据: $cd');
          daysToExam.value = cd.remainDays;
          examCountdownText.value = cd.remainText.isNotEmpty
              ? cd.remainText
              : (cd.remainDays > 0 ? '距离考试还有${cd.remainDays}天' : '');
        }
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = '网络错误 $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 打印当前全局设置（调试用）
  void printGlobalSettings() {
    debugPrint('---------- 全局设置 ----------');
    debugPrint(
        '当前项目: ${currentProject.value?.name ?? "无"} (ID: ${currentProject.value?.id})');
    debugPrint('当前模式: $currentModeName (${pageMode.value})');
    debugPrint(
        '当前科目: ${currentSubject.value.isEmpty ? "未选择" : currentSubject.value}');
    debugPrint(
        '当前章节: ${currentChapter.value.isEmpty ? "未选择" : currentChapter.value}');
    debugPrint('API状态: ${isLoading.value ? "加载中" : "完成"}');
    debugPrint(
        '错误信息: ${errorMessage.value.isEmpty ? "无" : errorMessage.value}');
    debugPrint('----------------------------');
  }

  // ==================== 私有方法 ====================

  String _resolveExamType() {
    final name = currentProject.value?.name ?? '';
    return _examRepository.resolveExamType(name);
  }

  void _initialize() {
    // 初始化 Repository
    _examRepository = Get.find<ExamRepository>();

    final storedProject = _storage.read(_storageKey);
    if (storedProject != null && storedProject is Map<String, dynamic>) {
      try {
        final project = Project.fromJson(storedProject);
        currentProject.value = project;

        final storedMode = _storage.read(_storageModeKey);
        if (storedMode != null && storedMode is String) {
          pageMode.value = storedMode;
        }

        loadApiData();
        printGlobalSettings();
        return;
      } catch (e) {
        debugPrint('解析存储的项目失败 $e');
      }
    }

    // 默认项目
    final defaultProject = Project(
      id: '5',
      name: '中级经济师',
      code: 'mid_economist',
      description: '中级经济师资格考试',
      icon: '',
      subjectCount: 2,
      questionCount: 2000,
    );
    selectProject(defaultProject);
  }

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    // 直接初始化，不使用 addPostFrameCallback 避免延迟
    _initialize();
  }
}
