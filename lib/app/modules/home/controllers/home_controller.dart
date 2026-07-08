// home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../routes/app_pages.dart';
import '../../../services/global_project_controller.dart';
import '../../../services/snackbar_utils.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/home_model.dart';
import '../../../data/models/version_model.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/repositories/exam_repository.dart';

class HomeController extends GetxController {
  // 当前项目标题
  final RxString currentProjectName = ''.obs;

  // 当前选中的tab索引 默认选中精选推
  final RxInt currentTabIndex = 0.obs;

  // 版本更新检测
  String _currentVersion = '1.0.0';
  bool _versionChecked = false;
  final Rx<VersionModel?> pendingUpdate = Rx<VersionModel?>(null);

  // ever 监听器引用，用于在 onClose 中释放
  Worker? _projectChangeWorker;

  // 切换科目
  void switchSubject() {
    Get.toNamed(Routes.PROJECT);
  }

  // 状态行点击事件
  void onStatusItemTap(String title) {
    switch (title) {
      case '模拟考试':
        Get.toNamed(Routes.QUESTIONS_EXAM);
        break;
      case '历年试卷':
        Get.toNamed(Routes.QUESTIONS_LIST);
        break;
      case '免费资料':
        Get.toNamed(Routes.STUDY);
        break;
      case '每日一练':
        Get.toNamed(
          '/question-train',
          preventDuplicates: false,
          arguments: {
            'subject': '每日一练',
            'mode': 'prac',
            '_ts': DateTime.now().millisecondsSinceEpoch,
          },
        );
        break;
      case '企业合作':
        Get.toNamed(Routes.ENTERPRISE_AGREEMENT);
        break;
      case '我的课程':
        Get.toNamed(Routes.MY_COURSES);
        break;
      default:
        SnackbarUtils.showInfo('功能开发中: $title');
        break;
    }
  }

  // 课程点击事件
  void onCourseTap(Map<String, dynamic> course) {
    Get.toNamed(Routes.STUDY, arguments: course);
  }

  // 广告横幅点击事件
  Future<void> onBannerTap(String url) async {
    if (url.isEmpty) {
      SnackbarUtils.showInfo('该广告没有链接');
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarUtils.showInfo('无法打开链接');
      }
    } catch (e) {
      SnackbarUtils.showInfo('链接格式错误');
    }
  }

  // 切换tab
  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  // 跳转到搜索页
  void goToSearch() {
    Get.toNamed(Routes.SEARCH);
  }

  // Repository 实例
  final ExamRepository _examRepository = ExamRepository.to;

  // 加载状态
  final RxBool isLoading = false.obs;

  // 公共接口返回的数据
  Rx<ApiResponse<HomeData>?> homeApiResponse = Rx<ApiResponse<HomeData>?>(null);

  @override
  void onInit() {
    super.onInit();
    // 初始化当前项目名称
    currentProjectName.value = GlobalProjectController.to.currentProjectName;

    // 加载首页公共接口数据
    loadHomeData();

    // 监听全局项目变化，保存 Worker 引用以便释放
    _projectChangeWorker =
        ever(GlobalProjectController.to.currentProject, (project) {
      currentProjectName.value = GlobalProjectController.to.currentProjectName;
      loadHomeData();
    });
  }

  @override
  void onClose() {
    _projectChangeWorker?.dispose();
    super.onClose();
  }

  /// 检测版本更新
  Future<void> checkVersion() async {
    if (_versionChecked) return;
    _versionChecked = true;

    try {
      // 自动读取 pubspec.yaml 中的版本号
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;

      final response = await ApiClient.to.initApp(
        version: _currentVersion,
      );

      debugPrint('版本检测响应: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('版本检测 data: $data');

        final rawData = data['data'];
        if (rawData is Map<String, dynamic>) {
          final versionData = rawData['versiondata'];
          debugPrint('版本检测 versionData: $versionData');

          VersionModel versionModel;
          if (versionData is Map<String, dynamic>) {
            versionModel = VersionModel.fromJson(versionData);
            debugPrint(
                'needUpdate: ${versionModel.needUpdate}, newVersion: ${versionModel.newVersion}');
          } else {
            versionModel = VersionModel.fromJson(null);
          }

          final hasNewerVersion = _isRemoteVersionNewer(
            versionModel.newVersion,
            _currentVersion,
          );
          debugPrint(
              '版本比较 currentVersion: $_currentVersion, newVersion: ${versionModel.newVersion}, hasNewerVersion: $hasNewerVersion');

          if (versionModel.needUpdate && hasNewerVersion) {
            pendingUpdate.value = versionModel;
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('版本检测失败: $e');
      debugPrint('堆栈: $stackTrace');
    }
  }

  bool _isRemoteVersionNewer(String? remoteVersion, String currentVersion) {
    final remoteParts = _parseVersionParts(remoteVersion);
    final currentParts = _parseVersionParts(currentVersion);

    if (remoteParts == null || currentParts == null) {
      return false;
    }

    final maxLength = remoteParts.length > currentParts.length
        ? remoteParts.length
        : currentParts.length;
    for (var i = 0; i < maxLength; i++) {
      final remotePart = i < remoteParts.length ? remoteParts[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;

      if (remotePart > currentPart) return true;
      if (remotePart < currentPart) return false;
    }

    return false;
  }

  List<int>? _parseVersionParts(String? version) {
    final value = version?.trim();
    if (value == null || value.isEmpty) return null;

    final coreVersion = value
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split(RegExp(r'[-+]'))
        .first
        .trim();
    if (coreVersion.isEmpty) return null;

    final parts = <int>[];
    for (final part in coreVersion.split('.')) {
      final number = int.tryParse(part);
      if (number == null) return null;
      parts.add(number);
    }

    return parts;
  }

  /// 获取企业合作配置并打开 H5 页面
  Future<void> fetchCompanyConfigAndOpenH5() async {
    try {
      final response = await ApiClient.to.exam(
        'common/getConfig',
        queryParameters: {'id': 1},
      );
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data['code'] == 1) {
        final config = data['data'] is Map
            ? Map<String, dynamic>.from(data['data'] as Map)
            : <String, dynamic>{};
        final value = config['company_report_config'];
        final url = value is String ? value.trim() : '';
        if (url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            Get.snackbar('提示', '无法打开链接');
          }
        } else {
          Get.snackbar('提示', '未获取到链接地址');
        }
      } else {
        Get.snackbar('提示', data?['msg'] ?? '获取企业合作配置失败');
      }
    } catch (e) {
      Get.snackbar('提示', '获取企业合作配置失败');
    }
  }

  /// 跳转下载页面
  Future<void> downloadUpdate(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar('提示', '下载地址不存在');
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('提示', '无法打开下载链接');
    }
  }

  // 加载首页公共接口数据
  Future<void> loadHomeData() async {
    isLoading.value = true;

    try {
      // 使用 Repository 获取首页数据
      final response = await _examRepository.getHomeData(
        subjectId: GlobalProjectController.to.currentProject.value?.id ?? '5',
      );
      homeApiResponse.value = response;
    } catch (e) {
      // 错误已在 Repository 中处理
    } finally {
      isLoading.value = false;
    }
  }
}
