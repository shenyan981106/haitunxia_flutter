import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xmshop/app/services/global_project_controller.dart';
import 'package:xmshop/app/data/models/question_model.dart';
import 'package:xmshop/app/data/providers/api_client.dart';
import 'package:xmshop/app/routes/app_pages.dart';
import 'package:xmshop/app/services/snackbar_utils.dart';
import 'package:xmshop/app/services/screenAdapter.dart';
import 'package:xmshop/app/data/services/auth_service.dart';
import 'package:xmshop/app/data/repositories/exam_repository.dart';
import 'package:xmshop/app/components/common_dialog.dart';

class QuestionTrainController extends GetxController {
  final GetStorage _box = GetStorage();
  final ExamRepository _examRepository = ExamRepository();

  // 记录每道题的开始时间（用于计算答题用时）
  DateTime? _questionStartTime;

  // 当前题目列表
  final RxList<Question> questions = <Question>[].obs;

  // 加载状态
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // 当前题目索引
  final RxInt currentQuestionIndex = 0.obs;

  // 用户答案记录：Map<题目索引, 用户选择的答案索引列表>
  final RxMap<int, List<int>> userAnswers = <int, List<int>>{}.obs;

  // 答题结果记录：Map<题目索引, 是否正确>
  final RxMap<int, bool> answerResults = <int, bool>{}.obs;

  // 收藏的题目：Map<题目索引, 是否收藏>
  final RxMap<int, bool> favoriteQuestions = <int, bool>{}.obs;

  // 收藏操作加载状态
  final RxBool isCollecting = false.obs;

  // 已记录答题日志的题目索引，防止重复记录
  final Set<int> _loggedQuestionIndices = <int>{};

  // 是否显示答案解释
  final RxBool showExplanation = false.obs;

  // 控制是否允许返回
  final RxBool canPopNow = false.obs;

  // 新增设置项状态
  final RxDouble fontSizeScale = 1.0.obs; // 字体大小缩放
  final RxDouble lineHeight = 1.5.obs; // 行距 (默认1.5)
  final RxBool isAutoNext = true.obs; // 自动跳转 (默认开启)
  final RxBool isAutoShowExplanation = false.obs; // 自动显示解析 (默认关闭)
  final RxBool isDarkMode = false.obs; // 夜间模式 (默认关闭)

  // 是否已看滑动提示
  final RxBool hasSeenSwipePrompt = false.obs;

  // 卡片显示控制
  final RxBool showFontSizeCard = false.obs; // 字体大小卡片
  final RxBool showSettingsCard = false.obs; // 设置卡片

  // 切换字体大小卡片
  void toggleFontSizeCard() {
    showFontSizeCard.toggle();
    if (showFontSizeCard.value) {
      showSettingsCard.value = false;
    }
  }

  // 切换设置卡片
  void toggleSettingsCard() {
    showSettingsCard.toggle();
    if (showSettingsCard.value) {
      showFontSizeCard.value = false;
    }
  }

  // 关闭所有卡片
  void closeAllCards() {
    showFontSizeCard.value = false;
    showSettingsCard.value = false;
  }

  // 是否详情模式 (用于看题模式切换列表/详情)
  final RxBool isDetailView = true.obs;

  // 是否已提交 (用于练习模式)
  final RxBool isSubmitted = false.obs;

  // 计时器（秒）
  final RxInt elapsedSeconds = 0.obs;
  final RxInt remainingSeconds = 0.obs; // 倒计时秒数
  Timer? _timer; // 使用可空类型，避免late 初始化问题
  int examInitialSeconds = 0; // 考试初始时间（秒）

  // 格式化倒计时/正计时
  bool get isCountdownMode {
    // 有 paperId 说明是试卷/真题模式，使用倒计时
    if (paperId != null) return true;
    // 无 paperId 但 EXAM 模式也用倒计时
    if (pageMode.value == 'EXAM') return true;
    // 章节练习（无 paperId）用正计时
    return false;
  }

  String get timerText {
    if (isCountdownMode) {
      int minutes = remainingSeconds.value ~/ 60;
      int seconds = remainingSeconds.value % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      int minutes = elapsedSeconds.value ~/ 60;
      int seconds = elapsedSeconds.value % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // 兼容旧代码引用
  String get remainingTimeText => timerText;

  // 页面控制
  final PageController pageController = PageController();

  // 当前科目和章节信息
  String subject = '';
  String chapter = '';
  String section = '';
  String subsection = '';

  // 页面来源类型（普通/收藏/试卷）
  String pageType = ''; // 'favorite' 表示收藏模式

  // 试卷信息
  int totalScore = 0;
  int passScore = 0;
  dynamic paperId; // 试卷ID
  dynamic pageConfigId; // 页面配置ID（动态配置模式）

  // 获取当前题目
  Question get currentQuestion => questions.isNotEmpty
      ? questions[currentQuestionIndex.value]
      : Question(
          id: '',
          projectId: '',
          subjectId: '',
          chapterId: '',
          type: 'single',
          content: '',
          options: [],
          correctAnswers: [],
          explanation: '',
          difficulty: 'medium',
        );

  // 获取当前题目的用户答案
  List<int>? get currentUserAnswer => userAnswers[currentQuestionIndex.value];

  // 当前页面模式：EXAM（考试模式）、TRAINING（练习模式）、VIEW（背题模式）
  final RxString pageMode = 'TRAINING'.obs;

  // 切换页面模式
  // TRAINING/EXAM: 答题模式（不显示答案，自动跳转下一题）
  // VIEW: 背题模式（显示答案解析，不自动跳转）
  void changePageMode(String mode) {
    final String oldMode = pageMode.value;

    if (oldMode == mode) return; // 模式没变则不处理

    pageMode.value = mode;

    // 同步更新全局状态（持久化存储）
    if (Get.isRegistered<GlobalProjectController>()) {
      GlobalProjectController.to.setPageMode(mode);
    }

    // 统一设置视图和解析状态
    isDetailView.value = true;
    showExplanation.value = false;

    print(
        '🔄🔄🔄 模式从 $oldMode 切换到 $mode (paperId=$paperId, pageType=$pageType) 🔄🔄🔄');

    // ====== 场景A：试卷模式切换到背题时重新加载 ======
    if (paperId != null && mode == 'VIEW' && oldMode != 'VIEW') {
      print('🔄 切换到背题模式，重新加载试卷数据以确保获取答案');
      _reloadForViewMode();
    }

    // ====== 场景B：收藏模式切换模式时的特殊处理 ======
    if (pageType == 'favorite') {
      if (mode == 'VIEW') {
        // 收藏→背题：直接切换即可，数据已有完整答案（收藏列表自带 answer 字段）
        print('📌 收藏模式切换到背题模式');
        showExplanation.value = false;
      } else {
        // 收藏→答题：重启计时器
        _ensureTimerRunning();
        print('📌 收藏模式切换到答题模式 计时器已启动');
      }
    } else {
      // ====== 场景C：普通试卷模式 ======
      // 切换回答题模式时重启计时器
      if (mode != 'VIEW' && paperId != null) {
        Future.delayed(Duration(milliseconds: 100), () => _startTimer());
      }
    }

    update();
  }

  /// 为背题模式重新加载数据（确保带答案）
  Future<void> _reloadForViewMode() async {
    isLoading.value = true;
    try {
      // 使用相同的 paperId 重新加载，_loadQuestionsFromPaper 内部已始终传 show_answer=1
      await _loadQuestionsFromPaper(paperId);

      // 检查加载后的数据是否有答案
      if (questions.isNotEmpty) {
        int answerCount =
            questions.where((q) => q.correctAnswers.isNotEmpty).length;
        print('背题模式重载完成: ${questions.length} $answerCount题有答案');

        if (answerCount == 0) {
          print('⚠️ 警告：所有题目都没有答案数据！接口可能未返回答案字段');
        }
      }
    } catch (e) {
      print('背题模式重载失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 设置字体大小
  void setFontSize(double scale) {
    fontSizeScale.value = scale;
    update();
  }

  // 设置行距
  void setLineHeight(double height) {
    lineHeight.value = height;
    update();
  }

  // 切换自动跳转
  void toggleAutoNext(bool value) {
    isAutoNext.value = value;
    update();
  }

  // 切换自动显示解析
  void toggleAutoShowExplanation(bool value) {
    isAutoShowExplanation.value = value;
    update();
  }

  // 切换夜间模式
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();

    // ====== 无法忽略的启动标志 ======
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('QuestionTrainController onInit 启动');
    debugPrint('时间: ${DateTime.now()}');
    debugPrint('╚══════════════════════════════════════╝');
    print(
        '🚀🚀🚀 QuestionTrainController onInit - NEW CODE LOADED at ${DateTime.now()} 🚀🚀🚀');

    // 初始化本地存储状态
    hasSeenSwipePrompt.value = _box.read('hasSeenSwipePrompt') ?? false;

    try {
      // 优先尝试从 URL 参数 获取参数，这通常更常用
      if (Get.parameters.containsKey('cate_id')) {
        var paramId = Get.parameters['cate_id'];
        // 尝试解析为 int 或保留为 String
        if (paramId != null && paramId.isNotEmpty) {
          // 如果是纯数字字符串，也可以转换为 int，但保留 string 也可以，只要后续处理一即可
          // 这里我们先存args 模拟结构，或者直接使用
          print('URL Parameters 获取cate_id: $paramId');
        }
      }

      // 获取传递的参数
      final dynamic args = Get.arguments;

      // 1. 初始化页面模式：优先使用全局配置，否则默认为 TRAINING
      try {
        if (Get.isRegistered<GlobalProjectController>()) {
          final globalMode =
              GlobalProjectController.to.pageMode.value.toString().trim();
          if (globalMode == 'TRAINING' ||
              globalMode == 'EXAM' ||
              globalMode == 'VIEW') {
            pageMode.value = globalMode;
            print('从全局配置初始化页面模式: ${pageMode.value}');
          } else {
            print('全局配置模式无效: $globalMode，使用默认值 TRAINING');
            pageMode.value = 'TRAINING';
          }
        }
      } catch (e) {
        print('获取全局页面模式失败: $e');
      }

      // 如果 pageMode 为空或无效，默认设置为 TRAINING
      if (pageMode.value.isEmpty) {
        pageMode.value = 'TRAINING';
        print('默认设置页面模式为 TRAINING');
      }

      // 调试信息
      print('QuestionTrainController Params: ${Get.parameters}');

      if (args != null && args is Map) {
        // 0. 识别页面来源类型（收藏模式）
        pageType = (args['pageType'] as String?) ?? '';

        // 收藏模式：使用 cate_name 作为标题
        if (pageType == 'favorite') {
          subject = (args['cate_name'] as String?) ?? '收藏题目';
          print('📌 检测到收藏模式: $subject');
        }

        // pageConfig 模式：从页面配置ID获取题目
        if (pageType == 'page_config') {
          pageConfigId = args['pageConfigId'];
          subject = (args['title'] as String?) ?? '题目练习';
          print('🔧 检测到页面配置模式: pageConfigId=$pageConfigId, title=$subject');
        }

        // 优先使用传递的 subject，如果没有则尝试使用 title (通常来自试卷列表)
        subject =
            (args['subject'] as String?) ?? (args['title'] as String?) ?? '';
        chapter = (args['chapter'] as String?) ?? '';
        section = (args['sectionTitle'] as String?) ?? '';
        subsection = (args['subsectionTitle'] as String?) ?? '';

        // 2. 如果传递了 mode 参数，覆盖全局配置
        if (args['mode'] != null) {
          final modeStr = args['mode'].toString().trim();
          if (modeStr == 'TRAINING' || modeStr == 'EXAM' || modeStr == 'VIEW') {
            pageMode.value = modeStr;
            print('从参数初始化页面模式: ${pageMode.value}');
          } else {
            print('无效的 mode 参数: $modeStr，保持当前模式 ${pageMode.value}');
          }
        }

        // 看题模式默认进入详情页（原为列表页，现已改为直接进入答题页）
        if (pageMode.value == 'VIEW') {
          isDetailView.value = true;
          // 看题模式初始不显示解析，点击选项后显示
          showExplanation.value = false;
        } else {
          isDetailView.value = true;
        }

        // 获取试卷信息
        totalScore = (args['total_score'] is int)
            ? args['total_score']
            : int.tryParse(args['total_score']?.toString() ?? '0') ?? 0;
        passScore = (args['pass_score'] is int)
            ? args['pass_score']
            : int.tryParse(args['pass_score']?.toString() ?? '0') ?? 0;
        paperId = args['paper_id'];
        print('🎯 paperId 赋值：$paperId (类型：${paperId.runtimeType})');

        // 初始化倒计时（试卷模式/考试模式）
        if (paperId != null || pageMode.value == 'EXAM') {
          int limitTime = (args['limit_time'] is int)
              ? args['limit_time']
              : int.tryParse(args['limit_time']?.toString() ?? '0') ?? 5400;
          // 如果没有传递 limit_time，默认90分钟(5400秒)
          if (limitTime <= 0) {
            limitTime = 5400;
            print('⚠️ limit_time 未设置或无效，使用默认值90分钟');
          }
          remainingSeconds.value = limitTime;
          examInitialSeconds = limitTime;
        }

        print(
            '接收到的参数: subject=$subject, chapter=$chapter, mode=${pageMode.value}, paperId=$paperId, remainingSeconds=${remainingSeconds.value}');
      }
    } catch (e) {
      print('接收参数时出错: $e');
    }

    // 启动计时器（所有模式都启动，根据 isCountdownMode 决定是否倒计时）
    // VIEW 模式也启动计时器（记录学习时长），但不强制要倒计时
    if (pageMode.value != 'VIEW') {
      _startTimer();
    }

    // 如果是看题模式，初始化不显示解析，等待用户点击选项后显示
    if (pageMode.value == 'VIEW') {
      showExplanation.value = false;
    } else if (pageMode.value == 'TRAINING') {
      // 练习模式默认不显示解析
      showExplanation.value = false;
    }

    // 加载题目数据
    _loadQuestions();
  }

  @override
  void onReady() {
    print('🚀 QuestionTrainController onReady called');
    super.onReady();
  }

  @override
  void onClose() {
    // 清理所有定时器（防止内存泄漏）
    _timer?.cancel();
    _timer = null;
    _multiSelectDebounceTimer?.cancel();
    _multiSelectDebounceTimer = null;
    _singleSelectTimer?.cancel();
    _singleSelectTimer = null;
    
    pageController.dispose();
    super.onClose();
  }

  // 加载题目数据
  Future<void> _loadQuestions() async {
    print(
        '📚 _loadQuestions 开始加载题目数据, paperId=$paperId, pageMode=${pageMode.value}');
    isLoading.value = true;
    errorMessage.value = '';
    questions.clear();

    try {
      final dynamic args = Get.arguments;
      dynamic cateId;

      // 检查是否从 paper_id 加载（真题模式）
      if (paperId != null) {
        print('📝 paperId 加载试题: $paperId');
        await _loadQuestionsFromPaper(paperId);
        return;
      }

      // 1. 优先从 URL Parameters 获取 cate_id
      if (Get.parameters.containsKey('cate_id')) {
        cateId = Get.parameters['cate_id'];
        print('QuestionTrainController: Got cate_id from parameters: $cateId');
      }

      print('QuestionTrainController _loadQuestions args: $args');

      if (cateId == null && args != null && args is Map) {
        // 2. 其次获取明确传递的 cate_id (arguments)
        cateId = args['cate_id'];

        // 如果没有，尝试从 id 获取
        if (cateId == null) {
          cateId = args['id'];
        }

        // 兼容旧的 sectionData 结构 (虽然 View 层已经简化，但保留逻辑以防万一)
        if (cateId == null && args['sectionData'] is Map) {
          final sectionData = args['sectionData'];
          cateId = sectionData['id'] ?? sectionData['cate_id'];
          if (cateId == null && sectionData['raw'] is Map) {
            final raw = sectionData['raw'];
            cateId = raw['id'] ?? raw['cate_id'];
          }
        }
      }

      print('Parsed cate_id: $cateId (Type: ${cateId.runtimeType})');

      // 收藏/错题模式：直接从传入的 items 列表构建题目，不需 cate_id
      if ((pageType == 'favorite' || pageType == 'wrong') && cateId == null) {
        print('📌 ${pageType == 'favorite' ? '收藏' : '错题'}模式：从 args.items 加载题目');
        if (pageType == 'wrong') {
          await _loadQuestionsFromWrong();
        } else {
          await _loadQuestionsFromFavorite();
        }
        return;
      }

      // 页面配置模式：通过 pageConfigId 获取题目
      if (pageType == 'page_config' && pageConfigId != null) {
        print('🔧 页面配置模式：通过 pageConfigId=$pageConfigId 获取题目');
        await _loadQuestionsFromPageConfig();
        return;
      }

      // 每日一练模式（prac）：不需要cate_id，随机返回10道题
      final isPracMode = (args?['mode']?.toString() ?? '') == 'prac';

      if (cateId == null && !isPracMode) {
        print('⚠️ 参数错误：cate_id 为空，无法发起请求');
        errorMessage.value = '参数错误：无法获取章节ID';
        isLoading.value = false;
        return;
      }

      // 构建请求参数
      final Map<String, dynamic> queryParams = {};
      if (cateId != null) {
        queryParams['cate_id'] = cateId;
      }
      if (paperId != null) {
        queryParams['paper_id'] = paperId;
      }

      // 添加 mode 参数
      if (isPracMode) {
        queryParams['mode'] = 'prac';
      } else if (pageMode.value == 'TRAINING') {
        queryParams['mode'] = 'normal';
      } else if (pageMode.value == 'EXAM') {
        queryParams['mode'] = 'exam';
      }

      print('Requesting questions with params: $queryParams');

      final response = await ApiClient.to.getExam(
        'question/train',
        queryParameters: queryParams,
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        var data = response.data;
        print('Raw Response Data Type: ${data.runtimeType}');

        // 处理 String 类型的响应数据
        if (data is String) {
          try {
            data = jsonDecode(data);
            print('Decoded JSON Data: $data');
          } catch (e) {
            print('JSON decode error: $e');
          }
        }

        // 兼容 code 为字符串的情况
        final code = data is Map ? data['code'] : null;
        final isSuccess = code == 1 || code == '1';

        if (data is Map && isSuccess) {
          final responseData = data['data'];
          print('Response Data Field: $responseData');

          List<dynamic> rawQuestions = [];

          if (responseData is Map && responseData.containsKey('data')) {
            rawQuestions = responseData['data'];
          } else if (responseData is List) {
            rawQuestions = responseData;
          }

          print('Raw Questions Count: ${rawQuestions.length}');

          if (rawQuestions.isEmpty) {
            errorMessage.value = '暂无题目数据';
          } else {
            final parsedQuestions = <Question>[];
            for (var q in rawQuestions) {
              try {
                parsedQuestions.add(_parseQuestion(q));
              } catch (e) {
                print('Error parsing question: $e, Data: $q');
              }
            }

            if (parsedQuestions.isEmpty) {
              errorMessage.value = '题目数据解析失败';
            } else {
              questions.assignAll(parsedQuestions);
              // 初始化收藏状态
              _initFavoriteStatus();
              // 跳转到第一个未做过的题
              _jumpToFirstUndoneQuestion();
            }
          }
        } else {
          errorMessage.value =
              data is Map ? (data['msg'] ?? '获取题目失败') : '数据格式错误';
        }
      } else {
        errorMessage.value = '网络请求失败: ${response.statusCode}';
      }
    } catch (e) {
      print('Error loading questions: $e');
      errorMessage.value = '加载题目出错，请稍后重试';
    } finally {
      isLoading.value = false;
    }
  }

  // ====== 从页面配置ID加载题目（动态配置模式）======
  Future<void> _loadQuestionsFromPageConfig() async {
    print('🔧 ===== _loadQuestionsFromPageConfig 开始 =====');
    print('🔧 pageConfigId=$pageConfigId, pageMode=${pageMode.value}');

    if (pageConfigId == null) {
      print('⚠️ 参数错误：pageConfigId 为空');
      errorMessage.value = '页面配置 ID 为空';
      isLoading.value = false;
      return;
    }

    try {
      final response = await ApiClient.to.getExam(
        'paper/getQuestionsByPageConfig',
        queryParameters: {'id': pageConfigId},
      );

      print('🔧 getQuestionsByPageConfig 返回: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == 1) {
          final listData = data['data'];
          final questionsRaw = (listData is Map)
              ? (listData['data'] as List?) ?? []
              : (listData is List ? listData : []);

          if (questionsRaw.isEmpty) {
            errorMessage.value = '暂无题目数据';
            print('⚠️ 页面配置返回题目为空');
          } else {
            print('🔧 获取 ${questionsRaw.length} 道题目');

            final parsedQuestions = <Question>[];
            for (var q in questionsRaw) {
              if (q is! Map) continue;
              try {
                final qMap = Map<String, dynamic>.from(q);
                parsedQuestions.add(_parseQuestion(qMap));
              } catch (e) {
                print('⚠️ 解析单题失败: $e, 数据: ${q.keys}');
              }
            }

            if (parsedQuestions.isNotEmpty) {
              questions.assignAll(parsedQuestions);
              _initFavoriteStatus();
              // 跳转到第一个未做过的题
              _jumpToFirstUndoneQuestion();
              _ensureTimerRunning();
              print('🔧 页面配置题目加载完成: ${parsedQuestions.length} 道题目');
            } else {
              errorMessage.value = '题目数据解析失败';
            }
          }
        } else {
          String msg = data['msg']?.toString() ?? '获取题目失败';
          // 检查是否需要开通会员
          final extra = data['data'];
          if (extra is Map && extra['need_open'] == true) {
            msg = '该功能仅针对会员开放，请开通会员后再试';
          }
          errorMessage.value = msg;
          print('⚠️ API返回错误: $msg');
        }
      } else {
        errorMessage.value = '网络请求失败: ${response.statusCode}';
        print('⚠️ 网络请求失败: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('🔧 _loadQuestionsFromPageConfig 错误: $e');
      print('堆栈: $stackTrace');
      errorMessage.value = '加载页面配置题目失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ====== 从试卷ID加载题目（真题模式）======
  // 根据 pageMode 决定是否请求带答案的数据
  Future<void> _loadQuestionsFromPaper(dynamic paperId) async {
    print(
        '📝📝📝📝📝 _loadQuestionsFromPaper 被调用！！！ paperId=$paperId, pageMode=${pageMode.value} 📝📝📝📝📝');

    if (paperId == null) {
      print('⚠️ paperId 为空，无法加载试题');
      errorMessage.value = '试卷 ID 为空';
      isLoading.value = false;
      return;
    }

    try {
      // 生成时间戳
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 始终请求带答案的数据（包括正确答案和解析）
      // 答案的显示隐藏由前端UI 层根pageMode showExplanation 控制，而非接口层面限制
      print('🌐 请求 API: paper/getExamQuestion');
      print('参数：paper_id=$paperId, timestamp=$timestamp, show_answer=1(始终)');

      final Map<String, dynamic> queryParams = {
        'paper_id': paperId,
        'timestamp': timestamp,
        'show_answer': 1,
      };

      final response = await ApiClient.to.getExam(
        'paper/getExamQuestion',
        queryParameters: queryParams,
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        var data = response.data;

        // 处理 String 类型的响应数据
        if (data is String) {
          try {
            data = jsonDecode(data);
            print('Decoded JSON Data: $data');
          } catch (e) {
            print('JSON decode error: $e');
          }
        }

        // 兼容 code 为字符串的情况
        final code = data is Map ? data['code'] : null;
        final isSuccess = code == 1 || code == '1';

        if (data is Map && isSuccess) {
          final responseData = data['data'];
          print('Response Data Field: $responseData');

          // ====== 从接口响应中提取试卷配置（含 limit_time）=====
          _extractPaperConfigFromResponse(responseData);

          List<dynamic> rawQuestions = [];

          // 解析题目列表
          if (responseData is Map) {
            // 优先检查 questions 字段（来paper API）
            if (responseData.containsKey('questions')) {
              rawQuestions = responseData['questions'];
              print('从 questions 字段获取题目');
            } else if (responseData.containsKey('list')) {
              rawQuestions = responseData['list'];
              print('从 list 字段获取题目');
            } else if (responseData.containsKey('paper') &&
                responseData['paper'] is Map) {
              // 有些 API 返回的是 { paper: {...}, questions: [...] }
              final paperData = responseData['paper'];
              if (paperData is Map && paperData.containsKey('questions')) {
                rawQuestions = paperData['questions'];
                print('从 paper.questions 字段获取题目');
              }
            }
          } else if (responseData is List) {
            rawQuestions = responseData;
            print('直接从 responseData 获取题目');
          }

          print('Raw Questions Count: ${rawQuestions.length}');

          if (rawQuestions.isEmpty) {
            errorMessage.value = '暂无题目数据';
            print('未找到题目数');
          } else {
            final parsedQuestions = <Question>[];
            for (var q in rawQuestions) {
              try {
                print('📝 解析题目 ${q['title']}');
                parsedQuestions.add(_parseQuestionFromPaper(q));
              } catch (e) {
                print('Error parsing question: $e, Data: $q');
              }
            }

            if (parsedQuestions.isEmpty) {
              errorMessage.value = '题目数据解析失败';
              print('题目解析后为空');
            } else {
              questions.assignAll(parsedQuestions);
              // 初始化收藏状态
              _initFavoriteStatus();
              // 跳转到第一个未做过的题目
              _jumpToFirstUndoneQuestion();
              print('成功加载 ${parsedQuestions.length} 道题');
              if (parsedQuestions.isNotEmpty) {
                final firstQ = parsedQuestions[0];
                print(
                    '📋 第一道题解析结果: answer=${firstQ.answer}, correctAnswers=${firstQ.correctAnswers}');
              }
            }
          }
        } else {
          errorMessage.value =
              data is Map ? (data['msg'] ?? '获取题目失败') : '数据格式错误';
          print('获取题目失败 ${errorMessage.value}');
        }
      } else {
        errorMessage.value = '网络请求失败 ${response.statusCode}';
        print('网络请求失败 ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading questions from paper: $e');
      errorMessage.value = '加载题目出错，请稍后重试';
    } finally {
      isLoading.value = false;
    }
  }

  // ====== 从收藏列表加载题目（收藏模式）=====
  Future<void> _loadQuestionsFromFavorite() async {
    print('📌 ===== _loadQuestionsFromFavorite 开始 =====');
    print('📌 pageType=$pageType, pageMode=${pageMode.value}');

    try {
      final dynamic args = Get.arguments;
      if (args is! Map) {
        print('args 不是 Map: ${args.runtimeType}');
        errorMessage.value = '收藏参数异常';
        return;
      }

      final itemsRaw = args['items'];
      print(
          '📌 itemsRaw 类型: ${itemsRaw.runtimeType}, 数量: ${itemsRaw is List ? itemsRaw.length : "N/A"}');

      if (itemsRaw is! List || itemsRaw.isEmpty) {
        print('items 为空或不是列表');
        errorMessage.value = '暂无收藏题目';
        return;
      }

      print('📌 收藏题目数量: ${itemsRaw.length}');
      final parsedQuestions = <Question>[];

      int parseSuccessCount = 0;

      for (int idx = 0; idx < itemsRaw.length; idx++) {
        final item = itemsRaw[idx];
        if (item is! Map) continue;

        final itemMap = item as Map;

        // ====== 提取基本字段 ======
        final questionId = itemMap['question_id']?.toString() ??
            itemMap['id']?.toString() ??
            '';

        // title 可能在顶层或question 子对象中
        String title = itemMap['title']?.toString() ?? '';

        // kind / answer 同理
        String kindStr =
            (itemMap['kind'] as String?)?.toUpperCase() ?? 'SINGLE';
        String answer = itemMap['answer']?.toString() ?? '';

        // options_json 可能在顶层或 question 子对象内
        // 注意：options_json 可能是 List<Map> 或 String，不能无类型
        dynamic rawOptionsJson;

        final topOptJson = itemMap['options_json'];
        if (topOptJson != null) {
          if (topOptJson is String && topOptJson.isNotEmpty) {
            rawOptionsJson = topOptJson;
          } else if (topOptJson is List && topOptJson.isNotEmpty) {
            rawOptionsJson = topOptJson;
          }
        }

        // 检查 question 子对象是否有更多/不同的数据
        final questionObj = itemMap['question'];
        if (questionObj is Map) {
          final qMap = <String, dynamic>{};
          for (final key in questionObj.keys) {
            qMap[key.toString()] = questionObj[key];
          }

          // 如果顶层没有 title，从子对象取
          if (title.isEmpty) title = qMap['title']?.toString() ?? '';
          // 如果顶层没有 kind，从子对象取
          if (kindStr == 'SINGLE' || kindStr.isEmpty) {
            kindStr = (qMap['kind']?.toString()?.toUpperCase()) ?? 'SINGLE';
          }
          // 如果顶层没有 answer，从子对象取
          if (answer.isEmpty) answer = qMap['answer']?.toString() ?? '';
          // 如果顶层没有 options_json，尝试从子对象取
          if (rawOptionsJson == null) {
            final subOpt = qMap['options_json'];
            if (subOpt is String && subOpt.isNotEmpty) {
              rawOptionsJson = subOpt;
            } else if (subOpt is List && subOpt.isNotEmpty) {
              rawOptionsJson = subOpt;
            }
          }
        }

        String kind = kindStr.toUpperCase().trim();
        if (kind.isEmpty) kind = 'SINGLE';

        print(
            '📌 题[$idx]: id=$questionId, kind=$kind, answer=$answer, optType=${rawOptionsJson?.runtimeType}');
        print(
            '📌 题[$idx]: title="${title.length > 50 ? title.substring(0, 50) : title}"');

        // ====== 解析选项 ======
        List<String> options = _parseOptionsDynamic(rawOptionsJson, kind);
        print('📌 题[$idx] 最终选项(${options.length}): $options');

        // ====== 计算正确答案索引 ======
        final correctAnswers = _parseAnswerToIndices(answer, options);
        print('📌 题[$idx] correctAnswers: $correctAnswers');

        // ====== 映射 kind 到 type 字符串 ======
        String type = 'single';
        if (kind.contains('MULTI')) {
          type = 'multi';
        } else if (kind == 'JUDGE') {
          type = 'judgment';
        }

        parsedQuestions.add(Question(
          id: questionId,
          projectId: '',
          subjectId: '',
          type: type,
          kind: kind,
          content: title,
          options: options,
          correctAnswers: correctAnswers,
          answer: answer,
          explanation: itemMap['explain']?.toString() ?? '',
          difficulty:
              (itemMap['difficulty'] as String?)?.toLowerCase() ?? 'medium',
          chapterId: '',
          isCollected: true,
        ));
        parseSuccessCount++;
      }

      print('📌 ===== 解析完成: 成功=$parseSuccessCount/${itemsRaw.length} =====');

      if (parsedQuestions.isEmpty) {
        errorMessage.value = '题目数据解析失败';
      } else {
        questions.assignAll(parsedQuestions);
        // 收藏模式全部标记为已收藏
        _initFavoriteStatus();
        // 跳转到第一个未做过的题目
        _jumpToFirstUndoneQuestion();

        // 收藏模式：确保计时器运行
        _ensureTimerRunning();

        print('📌 ===== 收藏题目加载完成: ${parsedQuestions.length} =====');
      }
    } catch (e, stackTrace) {
      print('_loadQuestionsFromFavorite 错误: $e');
      print('堆栈: $stackTrace');
      errorMessage.value = '加载收藏题目失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ====== 从错题列表加载题目（错题模式）逻辑与收藏模式一致
  Future<void> _loadQuestionsFromWrong() async {
    print('📌 ===== _loadQuestionsFromWrong 开始 =====');
    print('📌 pageType=$pageType, pageMode=${pageMode.value}');

    try {
      final dynamic args = Get.arguments;
      if (args is! Map) {
        print('args 不是 Map: ${args.runtimeType}');
        errorMessage.value = '错题参数异常';
        return;
      }

      final itemsRaw = args['items'];
      print(
          '📌 itemsRaw 类型: ${itemsRaw.runtimeType}, 数量: ${itemsRaw is List ? itemsRaw.length : "N/A"}');

      if (itemsRaw is! List || itemsRaw.isEmpty) {
        print('itemsRaw 为空或不是列表');
        errorMessage.value = '暂无错题';
        return;
      }

      print('📌 错题数量: ${itemsRaw.length}');
      final parsedQuestions = <Question>[];

      int parseSuccessCount = 0;

      for (int idx = 0; idx < itemsRaw.length; idx++) {
        final item = itemsRaw[idx];
        if (item is! Map) continue;

        final itemMap = item as Map;

        String type = 'single';
        final kindStr = (itemMap['kind'] as String?)?.toUpperCase() ?? '';
        if (kindStr.contains('MULTI')) {
          type = 'multi';
        } else if (kindStr.contains('JUDGE') ||
            kindStr == 'TRUE_FALSE' ||
            kindStr == 'TF') {
          type = 'judgment';
        } else if (kindStr.contains('FILL') || kindStr == 'BLANK') {
          type = 'fill';
        } else if (kindStr.contains('SHORT') ||
            kindStr == 'ESSAY' ||
            kindStr == 'QA') {
          type = 'short';
        } else if (kindStr.isNotEmpty) {
          type = kindStr;
        }

        final title = itemMap['title']?.toString() ?? '';
        if (title.isEmpty) continue;

        final options = _parseOptionsDynamic(itemMap['options_json'], type);

        final answerRaw = itemMap['answer']?.toString() ?? '';
        // 与收藏模式一致：将答案字符串转换为索引列表
        final correctAnswers = _parseAnswerToIndices(answerRaw, options);

        parsedQuestions.add(Question(
          id: (itemMap['question_id'] ?? itemMap['id'] ?? idx).toString(),
          projectId: '',
          subjectId: '',
          type: type,
          kind: kindStr,
          content: title,
          options: options,
          correctAnswers: correctAnswers,
          answer: answerRaw,
          explanation: itemMap['explain']?.toString() ?? '',
          difficulty:
              (itemMap['difficulty'] as String?)?.toLowerCase() ?? 'medium',
          chapterId: '',
          isCollected: false,
        ));
        parseSuccessCount++;
      }

      print('📌 ===== 解析完成: 成功=$parseSuccessCount/${itemsRaw.length} =====');

      if (parsedQuestions.isEmpty) {
        errorMessage.value = '题目数据解析失败';
      } else {
        questions.assignAll(parsedQuestions);
        _initFavoriteStatus();
        // 跳转到第一个未做过的题目
        _jumpToFirstUndoneQuestion();
        _ensureTimerRunning();
        print('📌 ===== 错题加载完成: ${parsedQuestions.length} =====');
      }
    } catch (e, stackTrace) {
      print('_loadQuestionsFromWrong 错误: $e');
      print('堆栈: $stackTrace');
      errorMessage.value = '加载错题失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 解析动态类型的 options_json（支持 List<Map> / String JSON / 非标准 toString 格式）
  List<String> _parseOptionsDynamic(dynamic rawOpt, String kind) {
    // 情况1: List<Map> 标准对象数组
    if (rawOpt is List) {
      final opts = <String>[];
      for (final item in rawOpt) {
        if (item is Map) {
          final val = item['value'] ?? item['text'] ?? item['content'];
          if (val != null) opts.add(val.toString());
        } else if (item != null) {
          final str = item.toString();
          if (str.isNotEmpty) opts.add(str);
        }
      }
      print('🔍 _parseOptionsDynamic: 从List提取 ${opts.length} 个选项');
      if (opts.isNotEmpty) return opts;
    }

    // 情况2: String 格式
    if (rawOpt is String && rawOpt.isNotEmpty) {
      final opts = _tryParseOptionsString(rawOpt);
      if (opts.isNotEmpty) return opts;
    }

    // 兜底：判断题默认选项
    if (kind.toUpperCase() == 'JUDGE') {
      return ['正确', '错误'];
    }

    print(
        '⚠️ _parseOptionsDynamic: 无法解析选项, type=${rawOpt?.runtimeType}, kind=$kind');
    return [];
  }

  /// 尝试解析 options_json 字符串（兼容标准 JSON 和非标准 Dart toString 格式）
  List<String> _tryParseOptionsString(String raw) {
    // 策略A: 直接当标准JSON 解析
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final sortedKeys = decoded.keys.map((k) => k.toString()).toList()
          ..sort();
        return sortedKeys
            .map((k) => decoded[k].toString())
            .where((v) => v.isNotEmpty)
            .toList();
      }
      if (decoded is List) {
        return _extractValuesFromList(decoded);
      }
    } catch (_) {}

    // 策略B: 修复非标准格式
    // 这种格式是 Dart Map/List 输出，key 没有引号
    if (raw.trimLeft().startsWith('[')) {
      try {
        final fixed = _fixDartToStringFormat(raw);
        if (fixed != null) {
          final decoded = jsonDecode(fixed);
          if (decoded is List) return _extractValuesFromList(decoded);
        }
      } catch (e) {
        print('⚠️ _tryParseOptionsString: 格式修复也失败 $e');
      }
    }

    // 策略C: 正则兜底
    // 直接从字符串中提取所有的 value
    return _regexExtractValues(raw);
  }

  /// 修复 Dart .toString() 输出为符合 JSON 格式
  /// 例如: [{key: A, value: 呈同方向变化}] --> [{"key":"A","value":"呈同方向变化"}]
  String? _fixDartToStringFormat(String input) {
    try {
      final result = StringBuffer();
      int i = 0;

      while (i < input.length) {
        final ch = input[i];

        if (ch == '{' || ch == '[' || ch == ']' || ch == ',' || ch == ':') {
          result.write(ch);
          i++;
          // 跳过空白
          while (i < input.length && (input[i] == ' ' || input[i] == '\n')) i++;
          continue;
        }
        if (ch == '}') {
          result.write(ch);
          i++;
          continue;
        }
        if (ch == '"') {
          // 已有的双引号字符串，原样保留
          result.write(ch);
          i++;
          while (i < input.length && input[i] != '"') {
            if (input[i] == '\\') {
              result.write(input[i]);
              i++;
              if (i < input.length) {
                result.write(input[i]);
                i++;
              }
            } else {
              result.write(input[i]);
              i++;
            }
          }
          if (i < input.length) {
            result.write('"');
            i++;
          }
          continue;
        }

        // 无引号的 token（key 或值）读取到分隔符为止
        final start = i;
        while (i < input.length && !_isMapSeparator(input[i])) i++;
        final token = input.substring(start, i).trim();
        if (token.isNotEmpty) {
          result.write('"$token"');
        }
      }

      return result.toString();
    } catch (e) {
      print('⚠️ _fixDartToStringFormat 异常: $e');
      return null;
    }
  }

  bool _isMapSeparator(String ch) {
    return ch == '{' ||
        ch == '}' ||
        ch == '[' ||
        ch == ']' ||
        ch == ',' ||
        ch == ':' ||
        ch == ' ';
  }

  /// 从解码后的 List 中提取 value 字段
  List<String> _extractValuesFromList(List decoded) {
    final opts = <String>[];
    for (final item in decoded) {
      if (item is Map) {
        final val = item['value'] ?? item['text'] ?? item['content'];
        if (val != null) opts.add(val.toString());
      } else if (item != null) {
        final str = item.toString();
        if (str.isNotEmpty) opts.add(str);
      }
    }
    print('🔍 _extractValuesFromList: 提取 ${opts.length} 个选项');
    return opts;
  }

  /// 正则兜底提取 value: xxx
  List<String> _regexExtractValues(String raw) {
    final results = <String>[];
    // 匹配 value: 后面的内容（支持无引号）
    final regex = RegExp(r'value\s*:\s*([^,\}\]]+?)');
    final matches = regex.allMatches(raw);

    for (final match in matches) {
      String val = match.group(1)?.trim() ?? '';
      // 去除可能的引号
      if ((val.startsWith("'") && val.endsWith("'")) ||
          (val.startsWith('"') && val.endsWith('"'))) {
        val = val.substring(1, val.length - 1);
      }
      if (val.isNotEmpty) results.add(val);
    }

    if (results.isNotEmpty) {
      print('🔍 _regexExtractValues: 用正则提取 ${results.length} 个选项');
    }
    return results;
  }

  /// 解析 options_json 为选项列表（仅处理 String 输入）
  List<String> _parseOptionsFromJson(
      String optionsJsonStr, String kind, String answer) {
    // 尝试解析 JSON
    if (optionsJsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(optionsJsonStr);
        if (decoded is Map) {
          // 按字母顺序排列
          final sortedKeys = decoded.keys.map((k) => k.toString()).toList()
            ..sort();
          final opts = sortedKeys
              .map((k) => decoded[k].toString())
              .where((v) => v.isNotEmpty)
              .toList();
          if (opts.isNotEmpty) return opts;
        } else if (decoded is List) {
          // 数组格式: ["选项A", "选项B", ...]
          final opts = decoded
              .map((v) => v.toString())
              .where((v) => v.isNotEmpty)
              .toList();
          if (opts.isNotEmpty) return opts;
        }
      } catch (e) {
        print('⚠️ options_json JSON解析失败: $e, 原始长度: ${optionsJsonStr.length}');
      }
    }

    // 降级处理：根据题型生成默认选项
    if (kind == 'JUDGE') {
      return ['正确', '错误'];
    }

    // 非判断题但无选项数据 返回UI 会显示"暂无选项"）
    print('⚠️ 无法解析选项，kind=$kind, answer=$answer');
    return [];
  }

  /// 将答案字符串(A/AB/ABC)转换为索引列表（[0], [0,1], [0,1,2]）
  List<int> _parseAnswerToIndices(String answer, List<String> options) {
    final indices = <int>[];
    if (answer.isEmpty) return indices;

    for (int i = 0; i < answer.length; i++) {
      final char = answer[i].toUpperCase();
      final code = char.codeUnitAt(0);
      if (code >= 65 && code <= 90) {
        // A-Z
        final idx = code - 65;
        // 只有在选项范围内才添加有效索引
        if (idx >= 0 && idx < options.length) {
          indices.add(idx);
        }
      }
    }
    return indices;
  }

  /// 确保计时器正在运行
  void _ensureTimerRunning() {
    if (_timer == null || !_timer!.isActive) {
      print('📌 启动计时器（当前模式: ${pageMode.value}, 倒计时: $isCountdownMode）');
      _startTimer();
    }
  }

  // ====== 从接口响应中提取试卷配置（limit_time、total_score 等）======
  void _extractPaperConfigFromResponse(dynamic responseData) {
    if (responseData is! Map) return;

    dynamic limitTimeSource;

    // 优先从 paper 字段获取
    if (responseData.containsKey('paper') && responseData['paper'] is Map) {
      final paperData = responseData['paper'] as Map<String, dynamic>;
      limitTimeSource = paperData['limit_time'];

      // 同时更新总分和及格分
      if (paperData.containsKey('total_score')) {
        totalScore = (paperData['total_score'] is int)
            ? paperData['total_score']
            : int.tryParse(paperData['total_score']?.toString() ?? '0') ??
                totalScore;
      }
      if (paperData.containsKey('pass_score')) {
        passScore = (paperData['pass_score'] is int)
            ? paperData['pass_score']
            : int.tryParse(paperData['pass_score']?.toString() ?? '0') ??
                passScore;
      }

      print(
          '📄 paper 字段提取配置: limit_time=$limitTimeSource, total_score=$totalScore, pass_score=$passScore');
    }

    // 其次尝试直接从 response data 获取
    if (limitTimeSource == null && responseData.containsKey('limit_time')) {
      limitTimeSource = responseData['limit_time'];
      print('📄 response data 提取 limit_time: $limitTimeSource');
    }

    // 解析并更新倒计时
    if (limitTimeSource != null) {
      int apiLimitTime = 0;
      if (limitTimeSource is int) {
        apiLimitTime = limitTimeSource;
      } else if (limitTimeSource is String) {
        apiLimitTime = int.tryParse(limitTimeSource) ?? 0;
      } else if (limitTimeSource is double) {
        apiLimitTime = limitTimeSource.toInt();
      }

      if (apiLimitTime > 0) {
        remainingSeconds.value = apiLimitTime;
        examInitialSeconds = apiLimitTime;
        print('倒计时已更新为接口返回值 ${apiLimitTime}秒(${apiLimitTime ~/ 60}分钟)');
      } else {
        print(
            '⚠️ 接口返回 limit_time 无效: $limitTimeSource，保持当前值 $remainingSeconds.value');
      }
    }
  }

  // 解析题目数据（从 paper API获取）
  Question _parseQuestionFromPaper(Map<String, dynamic> json) {
    // 解析题目 ID
    final questionId = json['id']?.toString() ?? '';

    // 解析题目类型
    String type = 'single';
    String kind = json['kind']?.toString() ?? 'SINGLE';

    // Map new kinds to functional types
    if (kind == 'MULTI' || kind == 'X') {
      type = 'multi';
    } else if (kind == 'JUDGE') {
      type = 'judgment';
    } else {
      type = 'single';
    }

    // 解析题目内容
    final content = json['title']?.toString() ?? '';

    // 解析选项
    List<String> options = [];

    // 1. 优先从 options 数组提取（List of Map/String）
    if (json['options'] is List) {
      options = (json['options'] as List)
          .map((opt) {
            if (opt is Map) {
              return opt['value']?.toString() ??
                  opt['text']?.toString() ??
                  opt['content']?.toString() ??
                  '';
            }
            return opt.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
      print('🔍[$questionId] options(List) 提取: $options');
    }

    // 2. options_json 提取 支支持 String List 两种格式
    if (options.isEmpty && json.containsKey('options_json')) {
      final rawOpt = json['options_json'];

      if (rawOpt is String && rawOpt.isNotEmpty) {
        // String 类型: {"A":"选项A","B":"选项B"} 或 [{"value":"A"},{"value":"B"}]
        try {
          final decoded = jsonDecode(rawOpt);
          if (decoded is Map) {
            // {"A":"xxx","B":"yyy"} --> A,B,C,D 顺序排列
            final sortedKeys = decoded.keys.map((k) => k.toString()).toList()
              ..sort();
            options = sortedKeys
                .map((k) => decoded[k].toString())
                .where((v) => v.isNotEmpty)
                .toList();
          } else if (decoded is List) {
            options = decoded
                .map((item) {
                  if (item is Map)
                    return item['value']?.toString() ??
                        item['text']?.toString() ??
                        '';
                  return item.toString();
                })
                .where((s) => s.isNotEmpty)
                .toList();
          }
          print('🔍[$questionId] options_json(String JSON) 提取: $options');
        } catch (e) {
          print(
              '⚠️[$questionId] options_json JSON解析失败: $e, 原始长度: ${rawOpt.length}');
        }
      } else if (rawOpt is List) {
        options = rawOpt
            .map((opt) {
              if (opt is Map)
                return opt['value']?.toString() ??
                    opt['text']?.toString() ??
                    '';
              return opt.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
        print('🔍[$questionId] options_json(List) 提取: $options');
      }
    }

    // 3. 兜底：判断题自动补全
    if (options.isEmpty && kind.toUpperCase() == 'JUDGE') {
      options = ['正确', '错误'];
      print('🔍[$questionId] 判断题使用默认选项: $options');
    }

    print(
        '🔍[$questionId] 最终选项: ${options.isEmpty ? "⚠️ 空！" : options} (kind=$kind, 原始options类型=${json['options']?.runtimeType}, options_json类型=${json['options_json']?.runtimeType})');

    // ====== 增强的答案解析逻辑 ======
    List<int> correctAnswers = [];
    String answerStr = '';

    // 1. 直接尝试多种可能的答案字段名（按优先级排序）
    final answerFieldNames = [
      'answer',
      'answer_key',
      'right_answer',
      'correct_answer',
      'ans',
      'true_answer',
      'standard_answer'
    ];
    for (var fieldName in answerFieldNames) {
      if (json.containsKey(fieldName) &&
          json[fieldName]?.toString().isNotEmpty == true) {
        answerStr = json[fieldName]!.toString();
        print('🔍[$questionId] 从字段 "$fieldName" 找到答案: $answerStr');
        break;
      }
    }

    // 2. 如果还没找到，尝试解析嵌套结构中的答案
    if (answerStr.isEmpty) {
      // 检查是否有 answer_object 或类似嵌套结构
      if (json['answer_object'] is Map) {
        answerStr = json['answer_object']['value']?.toString() ??
            json['answer_object']['answer']?.toString() ??
            '';
        if (answerStr.isNotEmpty)
          print('🔍[$questionId] answer_object 获取答案: $answerStr');
      }
    }

    print(
        '🔍 解析题目[$questionId] 答案: raw="$answerStr", 所有字段keys=${json.keys.toList()}');

    if (answerStr.isNotEmpty) {
      final answerKeys = answerStr.split(',').map((s) => s.trim()).toList();
      for (var key in answerKeys) {
        if (key.isNotEmpty) {
          int? index;
          // 支持大写字母 A,B,C...
          if (RegExp(r'^[A-Z]$').hasMatch(key)) {
            index = key.codeUnitAt(0) - 'A'.codeUnitAt(0);
          }
          // 支持小写字母 a,b,c...
          else if (RegExp(r'^[a-z]$').hasMatch(key)) {
            index = key.codeUnitAt(0) - 'a'.codeUnitAt(0);
          }
          // 支持数字 0,1,2...
          else if (RegExp(r'^\d+$').hasMatch(key)) {
            index = int.tryParse(key);
          }

          if (index != null && index >= 0) {
            correctAnswers.add(index);
          }
        }
      }
    }

    // 3. 如果还没找到答案，尝试从选项中提取（通过 is_right/is_correct 标记）
    if (correctAnswers.isEmpty && options.isNotEmpty) {
      print('🔍[$questionId] 尝试从选项中提取答案 options原始数据: ${json['options']}');

      // 先检查 options 数组
      if (json['options'] is List) {
        int optIndex = 0;
        for (var opt in json['options']) {
          if (opt is Map) {
            final isRight = opt['is_right'] == true ||
                opt['is_correct'] == true ||
                opt['is_answer'] == true ||
                opt['right'] == 1 ||
                opt['correct'] == 1;
            if (isRight) {
              correctAnswers.add(optIndex);
              print('🔍[$questionId] 选项$optIndex 标记为正确答案');
            }
          }
          optIndex++;
        }
      }

      // 再检查 options_json 数组
      if (correctAnswers.isEmpty && json['options_json'] is List) {
        int optIndex = 0;
        for (var opt in json['options_json']) {
          if (opt is Map) {
            final isRight = opt['is_right'] == true ||
                opt['is_correct'] == true ||
                opt['is_answer'] == true ||
                opt['right'] == 1;
            if (isRight) {
              correctAnswers.add(optIndex);
            }
          }
          optIndex++;
        }
      }

      if (correctAnswers.isNotEmpty) {
        answerStr =
            correctAnswers.map((i) => String.fromCharCode(65 + i)).join(',');
        print('🔍[$questionId] 从选项中提取到答案: $answerStr');
      }
    }

    // 4. 最后的诊断日志
    if (correctAnswers.isEmpty) {
      print('⚠️[$questionId] ⚠️ 未找到任何答案数据！题目可能缺少答案字段');
      print('⚠️[$questionId] 完整JSON数据: $json');
    } else {
      print('✅[$questionId] 成功解析答案: $answerStr -> indices=$correctAnswers');
    }

    // 解析解析（支持更多字段名）
    final explanation = json['explain']?.toString() ??
        json['explanation']?.toString() ??
        json['analysis']?.toString() ??
        json['content']?.toString() ?? // 有些API用content存解析
        '';

    // 解析难度
    String difficulty = 'medium';
    final difficultyStr = json['difficulty']?.toString() ?? '';
    if (difficultyStr == 'EASY') {
      difficulty = 'easy';
    } else if (difficultyStr == 'HARD') {
      difficulty = 'hard';
    }

    // 解析收藏状态
    final isCollected = json['collected'] == true ||
        json['collected'] == 1 ||
        json['is_collected'] == true;

    return Question(
      id: questionId,
      projectId: json['project_id']?.toString() ?? '',
      subjectId: json['subject_id']?.toString() ?? '',
      chapterId: json['chapter_id']?.toString() ?? '',
      type: type,
      kind: kind,
      content: content,
      options: options,
      correctAnswers: correctAnswers,
      answer: answerStr.isNotEmpty ? answerStr : null,
      explanation: explanation,
      difficulty: difficulty,
      isCollected: isCollected,
      cateId: json['cate_id']?.toString() ?? '',
    );
  }

  Question _parseQuestion(Map<String, dynamic> json) {
    // 解析题目 ID
    final questionId = json['id']?.toString() ?? '';

    // 解析题目类型
    String type = 'single';
    String kind = json['kind']?.toString() ?? 'SINGLE';

    if (kind == 'MULTI' || kind == 'X') {
      type = 'multi';
    } else if (kind == 'JUDGE') {
      type = 'judgment';
    } else {
      type = 'single';
    }

    // ====== 解析选项（增强版：兼容多种数据格式）======
    List<String> options = [];

    // 1. 优先检查 options 数组提取（List of Map/String）
    if (json['options'] is List) {
      options = (json['options'] as List)
          .map((opt) {
            if (opt is Map) {
              return opt['value']?.toString() ??
                  opt['text']?.toString() ??
                  opt['content']?.toString() ??
                  '';
            }
            return opt.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
      print('🔍[$questionId] options(List) 提取: $options');
    }

    // 2. options_json 提取（支持 String/List 两种格式）
    if (options.isEmpty && json.containsKey('options_json')) {
      final rawOpt = json['options_json'];

      if (rawOpt is String && rawOpt.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawOpt);
          if (decoded is Map) {
            final sortedKeys = decoded.keys.map((k) => k.toString()).toList()
              ..sort();
            options = sortedKeys
                .map((k) => decoded[k].toString())
                .where((v) => v.isNotEmpty)
                .toList();
          } else if (decoded is List) {
            options = decoded
                .map((item) {
                  if (item is Map)
                    return item['value']?.toString() ??
                        item['text']?.toString() ??
                        '';
                  return item.toString();
                })
                .where((s) => s.isNotEmpty)
                .toList();
          }
          print('🔍[$questionId] options_json(String JSON) 提取: $options');
        } catch (e) {
          print('⚠️[$questionId] options_json JSON解析失败: $e');
          // 尝试使用动态解析器
          options = _parseOptionsDynamic(rawOpt, kind);
        }
      } else if (rawOpt is List) {
        options = rawOpt
            .map((opt) {
              if (opt is Map)
                return opt['value']?.toString() ??
                    opt['text']?.toString() ??
                    '';
              return opt.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
        print('🔍[$questionId] options_json(List) 提取: $options');
      }
    }

    // 3. 兜底：判断题自动补全
    if (options.isEmpty && kind.toUpperCase() == 'JUDGE') {
      options = ['正确', '错误'];
      print('🔍[$questionId] 判断题使用默认选项: $options');
    }

    print('🔍[$questionId] 最终选项: ${options.isEmpty ? "⚠️ 空！" : options}');

    // ====== 解析答案（增强版：兼容多种数据格式）======
    List<int> correctAnswers = [];
    String answerStr = '';

    // 1. 直接尝试多种可能的答案字段名
    final answerFieldNames = [
      'answer',
      'answer_key',
      'right_answer',
      'correct_answer',
      'ans',
      'true_answer',
      'standard_answer'
    ];
    for (var fieldName in answerFieldNames) {
      if (json.containsKey(fieldName) &&
          json[fieldName]?.toString().isNotEmpty == true) {
        answerStr = json[fieldName]!.toString();
        print('🔍[$questionId] 从字段 "$fieldName" 找到答案: $answerStr');
        break;
      }
    }

    if (answerStr.isNotEmpty) {
      final answerKeys = answerStr.split(',').map((s) => s.trim()).toList();
      for (var key in answerKeys) {
        if (key.isNotEmpty) {
          int? index;
          if (RegExp(r'^[A-Z]$').hasMatch(key)) {
            index = key.codeUnitAt(0) - 'A'.codeUnitAt(0);
          } else if (RegExp(r'^[a-z]$').hasMatch(key)) {
            index = key.codeUnitAt(0) - 'a'.codeUnitAt(0);
          } else if (RegExp(r'^\d+$').hasMatch(key)) {
            index = int.tryParse(key);
          }

          if (index != null && index >= 0) {
            correctAnswers.add(index);
          }
        }
      }
    }

    // 2. 如果还没找到答案，尝试从选项中提取
    if (correctAnswers.isEmpty && options.isNotEmpty) {
      if (json['options'] is List) {
        int optIndex = 0;
        for (var opt in json['options']) {
          if (opt is Map) {
            final isRight = opt['is_right'] == true ||
                opt['is_correct'] == true ||
                opt['is_answer'] == true ||
                opt['right'] == 1 ||
                opt['correct'] == 1;
            if (isRight) correctAnswers.add(optIndex);
          }
          optIndex++;
        }
      }
      if (correctAnswers.isEmpty && json['options_json'] is List) {
        int optIndex = 0;
        for (var opt in json['options_json']) {
          if (opt is Map) {
            final isRight = opt['is_right'] == true ||
                opt['is_correct'] == true ||
                opt['is_answer'] == true;
            if (isRight) correctAnswers.add(optIndex);
          }
          optIndex++;
        }
      }
      if (correctAnswers.isNotEmpty) {
        answerStr =
            correctAnswers.map((i) => String.fromCharCode(65 + i)).join(',');
        print('🔍[$questionId] 从选项中提取到答案: $answerStr');
      }
    }

    if (correctAnswers.isEmpty) {
      print('⚠️[$questionId] 未找到任何答案数据！');
    } else {
      print('✅[$questionId] 成功解析答案: $answerStr -> indices=$correctAnswers');
    }

    // 解析 question_status
    int? questionStatus;
    if (json.containsKey('question_status')) {
      final qs = json['question_status'];
      if (qs is int) {
        questionStatus = qs;
      } else {
        questionStatus = int.tryParse(qs.toString());
      }
    }

    // 解析用户之前选择的答案（用于恢复已答记录）
    List<int>? parsedUserAnswer;
    final userAnswerFields = [
      'user_answer',
      'my_answer',
      'selected_answer',
      'last_answer'
    ];
    for (var fieldName in userAnswerFields) {
      if (json.containsKey(fieldName) && json[fieldName] != null) {
        final ua = json[fieldName];
        if (ua is List) {
          parsedUserAnswer = ua
              .map((e) {
                if (e is int) return e;
                if (e is String) {
                  // 支持字母格式 A,B,C -> 0,1,2
                  if (RegExp(r'^[A-Z]$').hasMatch(e)) {
                    return e.codeUnitAt(0) - 'A'.codeUnitAt(0);
                  } else if (RegExp(r'^[a-z]$').hasMatch(e)) {
                    return e.codeUnitAt(0) - 'a'.codeUnitAt(0);
                  }
                  return int.tryParse(e) ?? -1;
                }
                return -1;
              })
              .where((i) => i >= 0)
              .toList();
          if (parsedUserAnswer.isNotEmpty) {
            print('🔍[$questionId] 从字段 "$fieldName" 找到用户答案: $parsedUserAnswer');
            break;
          }
        } else if (ua is String && ua.isNotEmpty) {
          // 支持字符串格式 "A" 或 "A,B"
          final answerKeys = ua.split(',').map((s) => s.trim()).toList();
          final indices = <int>[];
          for (var key in answerKeys) {
            if (key.isEmpty) continue;
            int? index;
            if (RegExp(r'^[A-Z]$').hasMatch(key)) {
              index = key.codeUnitAt(0) - 'A'.codeUnitAt(0);
            } else if (RegExp(r'^[a-z]$').hasMatch(key)) {
              index = key.codeUnitAt(0) - 'a'.codeUnitAt(0);
            } else if (RegExp(r'^\d+$').hasMatch(key)) {
              index = int.tryParse(key);
            }
            if (index != null && index >= 0) {
              indices.add(index);
            }
          }
          if (indices.isNotEmpty) {
            parsedUserAnswer = indices;
            print(
                '🔍[$questionId] 从字段 "$fieldName" 找到用户答案(字符串): $parsedUserAnswer');
            break;
          }
        }
      }
    }

    return Question(
      id: questionId,
      projectId: json['project_id']?.toString() ?? '',
      subjectId: json['subject_id']?.toString() ?? '',
      chapterId: json['chapter_id']?.toString() ?? '',
      type: type,
      kind: kind,
      content: json['title']?.toString() ?? '',
      options: options,
      correctAnswers: correctAnswers,
      answer: answerStr.isNotEmpty ? answerStr : null,
      explanation: json['explain']?.toString() ??
          json['explanation']?.toString() ??
          json['analysis']?.toString() ??
          '',
      difficulty: _parseDifficulty(json['difficulty']),
      isCollected: json['collected'] == true ||
          json['collected'] == 1 ||
          json['is_collected'] == true,
      cateId: json['cate_id']?.toString() ?? '',
      questionStatus: questionStatus,
      userAnswer: parsedUserAnswer,
    );
  }

  String _parseDifficulty(dynamic difficulty) {
    if (difficulty == 'EASY') return 'easy';
    if (difficulty == 'HARD') return 'hard';
    return 'medium'; // GENERAL -> medium
  }

  // 获取题型文本（供视图层使用）
  String getQuestionTypeText(Question question) {
    switch (question.kind) {
      case 'X':
        return '不定项选择题';
      case 'JUDGE':
        return '判断题';
      case 'SINGLE':
        return '单选题';
      case 'MULTI':
        return '多选题';
      case 'FILL':
        return '填空题';
      case 'SHORT':
        return '简答题';
      case 'MATERIAL':
        return '材料题';
      default:
        switch (question.type) {
          case 'single':
            return '单选题';
          case 'multi':
            return '多选题';
          case 'judgment':
            return '判断题';
          default:
            return '选择题';
        }
    }
  }

  // 格式化答案索引为字母（如 [0,1] -> "A,B"）
  String formatAnswerIndices(List<int> indices) {
    if (indices.isEmpty) return '未答';
    return indices.map((i) => String.fromCharCode(65 + i)).join(',');
  }

  // 开始计时
  void _startTimer() {
    // 确保先取消已有计时器
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isCountdownMode) {
        if (remainingSeconds.value > 0) {
          remainingSeconds.value--;
        } else {
          timer.cancel();
          submitExam(auto: true);
        }
      } else {
        elapsedSeconds.value++;
      }
    });
  }

  // 交卷 - 调用后端 API
  void submitExam({bool auto = false}) async {
    if (auto) {
      Get.back(); // 返回上一页面
      SnackbarUtils.showInfo("时间已到，自动交卷");
      return;
    }

    final confirm = await showConfirmDialog();
    if (!confirm) return;

    // 构建提交数据 - 按照后端要求的格式：{0: {id: xxx, answer: "A", material_id: 0}, 1: {...}}
    // 提交所有题目（包括未作答的，answer 为空字符串）
    final questionsData = <String, Map<String, dynamic>>{};
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[i];

      // 将选项索引转换为字母（如 [0,1] -> "A,B"）
      String answerLetters = '';
      if (userAnswer != null && userAnswer.isNotEmpty) {
        answerLetters = userAnswer.map((idx) {
          return String.fromCharCode('A'.codeUnitAt(0) + idx);
        }).join(',');
      }

      // id 转为整数
      final questionIdInt = question.id is int
          ? question.id
          : int.tryParse(question.id.toString()) ?? 0;

      questionsData[i.toString()] = {
        'id': questionIdInt,
        'answer': answerLetters,
        'material_id': 0,
      };
    }

    // 计算已用时间
    int usedSeconds = pageMode.value == 'EXAM'
        ? ((examInitialSeconds - remainingSeconds.value)
                .clamp(0, examInitialSeconds))
            .toInt()
        : elapsedSeconds.value;

    // 调试：打印提交数据
    print('📝 提交数据:');
    print('  paper_id: $paperId (类型: ${paperId?.runtimeType})');
    print('  questions: $questionsData');
    print(
        '  start_time: ${DateTime.now().millisecondsSinceEpoch ~/ 1000 - usedSeconds}');
    print('  已答题目数 ${userAnswers.length}/${questions.length}');

    // ====== 分支处理：有 paperId vs 无 paperId ======
    final int paperIdInt =
        paperId is int ? paperId : int.tryParse(paperId.toString()) ?? 0;

    if (paperIdInt != 0) {
      // ====== 有 paperId：走原有的试卷/真题提交逻辑 ======
      await _submitPaperExam(paperIdInt, usedSeconds, questionsData);
    } else {
      // ====== 无 paperId：章节练习模式交卷 ======
      await _submitChapterPractice(usedSeconds, questionsData);
    }
  }

  // 试卷/真题模式交卷（原有逻辑）
  Future<void> _submitPaperExam(
    int paperIdInt,
    int usedSeconds,
    Map<String, Map<String, dynamic>> questionsData,
  ) async {
    try {
      isLoading.value = true;

      final formDataMap = <String, dynamic>{
        'paper_id': paperIdInt,
        'start_time':
            DateTime.now().millisecondsSinceEpoch ~/ 1000 - usedSeconds,
        'room_id': 0,
        'room_grade_id': 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      questionsData.forEach((key, value) {
        formDataMap['questions[$key][id]'] = value['id'];
        formDataMap['questions[$key][answer]'] = value['answer'];
        formDataMap['questions[$key][material_id]'] = value['material_id'];
      });

      final formData = dio.FormData.fromMap(formDataMap);

      final response = await ApiClient.to.postExam(
        'paper/submit',
        data: formData,
      );

      isLoading.value = false;

      if (response.statusCode == 200 && response.data['code'] == 1) {
        _navigateToResultPage(response.data['data'], usedSeconds);
      } else {
        SnackbarUtils.showError(response.data['msg'] ?? '提交失败，请重试');
      }
    } catch (e, stackTrace) {
      isLoading.value = false;
      _handleSubmitError(e, stackTrace);
    }
  }

  // 章节练习模式交卷（无 paperId）
  Future<void> _submitChapterPractice(
    int usedSeconds,
    Map<String, Map<String, dynamic>> questionsData,
  ) async {
    try {
      isLoading.value = true;

      // 统计答题结果并记录日志
      int correctCount = 0;
      int wrongCount = 0;
      int answeredCount = 0;

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final userAnswer = userAnswers[i];

        if (userAnswer != null && userAnswer.isNotEmpty) {
          answeredCount++;
          final isCorrect = _listEquals(userAnswer, question.correctAnswers);

          if (isCorrect) {
            correctCount++;
          } else {
            wrongCount++;
          }

          // 记录每道已答题目的日志（如果之前没记录过的话）
          if (!_loggedQuestionIndices.contains(i)) {
            final cateId = int.tryParse(question.cateId) ?? 0;
            final questionId = int.tryParse(question.id) ?? 0;

            String userAnswerStr = userAnswer.map((e) {
              return String.fromCharCode('A'.codeUnitAt(0) + e);
            }).join(',');

            await _addQuestionLog(
              questionId: questionId,
              cateId: cateId,
              userAnswer: userAnswerStr,
              isCorrect: isCorrect ? 1 : 0,
              timeSpent: 0,
              sourceType: 'TRAIN',
              sourceId: 0,
            );

            _loggedQuestionIndices.add(i);
          }
        }
      }

      isLoading.value = false;

      print(
          '✅ 章节练习交卷完成: 已答$answeredCount, 正确$correctCount, 错误$wrongCount, 总计${questions.length}');

      String nickname = '未设';
      try {
        nickname = AuthService.to.nickname ?? '未设';
      } catch (e) {
        print('获取昵称失败: $e');
      }

      final double scorePercent = answeredCount > 0
          ? (correctCount / answeredCount * 100).roundToDouble()
          : 0.0;
      final bool passed = scorePercent >= 60;

      Get.toNamed(
        Routes.QUESTIONS_RESULT,
        arguments: {
          'title': subject.isNotEmpty ? subject : '章节练习',
          'nickname': nickname,
          'durationSeconds': usedSeconds,
          'totalScore': 100,
          'passScore': 60,
          'questionCount': questions.length,
          'answeredCount': answeredCount,
          'correctCount': correctCount,
          'wrongCount': wrongCount,
          'score': scorePercent.toInt(),
          'passed': passed,
        },
      );
    } catch (e, stackTrace) {
      isLoading.value = false;
      print('章节练习交卷出错: $e');
      print('堆栈: $stackTrace');
      SnackbarUtils.showError('交卷失败: $e');
    }
  }

  // 跳转到结果页面（统一方法）
  void _navigateToResultPage(dynamic resultData, int usedSeconds) {
    final int finalScore = resultData['score'] ?? 0;
    final int total = resultData['total_question'] ?? questions.length;

    int clientWrongCount = 0;
    int clientAnsweredCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers.containsKey(i) && (userAnswers[i]?.isNotEmpty ?? false)) {
        clientAnsweredCount++;
        if (answerResults[i] != null && !answerResults[i]!) {
          clientWrongCount++;
        }
      }
    }
    final int wrongCount = clientWrongCount;
    final int correctCount = clientAnsweredCount - clientWrongCount;
    final bool passed = resultData['is_passed'] ?? (finalScore >= passScore);

    String nickname = '未设';
    try {
      nickname = AuthService.to.nickname ?? '未设';
    } catch (e) {
      print('获取昵称失败: $e');
    }

    Get.toNamed(
      Routes.QUESTIONS_RESULT,
      arguments: {
        'title': subject.isNotEmpty ? subject : '考试试卷',
        'nickname': nickname,
        'durationSeconds': usedSeconds,
        'totalScore': totalScore,
        'passScore': passScore > 0 ? passScore : 60,
        'questionCount': total,
        'answeredCount': clientAnsweredCount,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'score': finalScore,
        'passed': passed,
        'grade_id': resultData['grade_id'],
      },
    );
  }

  // 处理交卷错误（统一方法）
  void _handleSubmitError(dynamic e, StackTrace stackTrace) {
    print('交卷出错: $e');
    print('堆栈: $stackTrace');
    if (e is dio.DioException) {
      print('=== 完整错误响应 ===');
      print('Status: ${e.response?.statusCode}');
      final data = e.response?.data?.toString() ?? '';
      for (int i = 0; i < data.length; i += 1000) {
        final end = (i + 1000 < data.length) ? i + 1000 : data.length;
        print(data.substring(i, end));
      }
      print('===================');
    }
    SnackbarUtils.showError('提交失败: $e');
  }

  // 显示确认对话框
  Future<bool> showConfirmDialog() async {
    int answeredCount = userAnswers.length;
    int unansweredCount = questions.length - answeredCount;

    return await CommonDialog.show(
      title: '温馨提示',
      content: '当前已答题目 $answeredCount道，未答题目$unansweredCount道，是否确定交卷？',
      confirmText: '确定交卷',
      cancelText: '取消',
      barrierDismissible: false,
    );
  }

  // 标记滑动提示已读
  void markSwipePromptAsSeen() {
    hasSeenSwipePrompt.value = true;
    _box.write('hasSeenSwipePrompt', true);
  }

  Timer? _multiSelectDebounceTimer;
  Timer? _singleSelectTimer;

  // 选择答案 - 核心交互逻辑
  // 答题模式(TRAINING/EXAM): 不显示答案，自动跳转下一题
  // 背题模式(VIEW): 显示答案解析，不自动跳转
  void selectAnswer(int optionIndex) {
    // 练习模式下，如果显示了解析（已提交），则不能修改答案
    if ((pageMode.value == 'TRAINING' || pageMode.value == 'EXAM') &&
        showExplanation.value) return;

    final currentIndex = currentQuestionIndex.value;
    final question = questions[currentIndex];

    if (question.type == 'single' || question.type == 'judgment') {
      // 单选题或判断题：直接赋值
      final newAnswer = [optionIndex];
      userAnswers[currentIndex] = newAnswer;
      // 调用 _checkAnswer 方法，同时记录答题时间
      _checkAnswer(currentIndex, newAnswer);

      // 使用微任务确保UI更新后再执行后续逻辑
      Future.microtask(() {
        if (pageMode.value == 'VIEW') {
          // ====== 背题模式 ======
          // 显示答案解析，不自动跳转，用户手动滑动看下一题
          showExplanation.value = true;
        } else {
          // ====== 答题模式 (TRAINING/EXAM) ======
          // 不显示解析，自动跳转到下一题
          _scheduleAutoNext(currentIndex, isMulti: false);
        }
      });
    } else {
      // 多选题：切换选中状态
      final currentAnswers = List<int>.from(userAnswers[currentIndex] ?? []);
      if (currentAnswers.contains(optionIndex)) {
        currentAnswers.remove(optionIndex);
      } else {
        currentAnswers.add(optionIndex);
        currentAnswers.sort();
      }
      userAnswers[currentIndex] = currentAnswers;
      // 调用 _checkAnswer 方法，同时记录答题时间
      _checkAnswer(currentIndex, currentAnswers);

      Future.microtask(() {
        if (pageMode.value == 'VIEW') {
          // ====== 背题模式 ======
          // 显示答案解析，不自动跳转
          showExplanation.value = true;
        } else {
          // ====== 答题模式 (TRAINING/EXAM) ======
          // 自动跳转到下一题
          _scheduleAutoNext(currentIndex, isMulti: true);
        }
      });
    }

    // 考试模式自动保存进度
    if (pageMode.value == 'EXAM') {
      _saveExamProgress();
    }
  }

  // 延迟自动跳转下一题（仅用于答题模式 TRAINING/EXAM)
  void _scheduleAutoNext(int currentIndex, {required bool isMulti}) {
    if (!isAutoNext.value) return; // 用户关闭了自动跳转
    final timer = isMulti ? _multiSelectDebounceTimer : _singleSelectTimer;
    timer?.cancel();

    // 单选题或判断题延迟500ms跳转，让用户看清楚选中效果
    // 多选题延迟1200ms，让用户有时间选择多个答案
    final delayMs = isMulti ? 1200 : 500;

    final newTimer = Timer(
      Duration(milliseconds: delayMs),
      () {
        if (currentQuestionIndex.value == currentIndex) {
          if (currentIndex < questions.length - 1) {
            // 答题模式：直接跳转下一题，不显示解析
            pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } else {
            // 最后一题：弹出答题结果
            showAnswerCard();
          }
        }
      },
    );

    if (isMulti) {
      _multiSelectDebounceTimer = newTimer;
    } else {
      _singleSelectTimer = newTimer;
    }
  }

  // 检查答题结果
  // 记录答题时间
  void _checkAnswer(int index, List<int> userAnswer) {
    final question = questions[index];
    final isCorrect = _listEquals(userAnswer, question.correctAnswers);
    answerResults[index] = isCorrect;

    // 检查是否已记录过这道题的日志，防止重复记录
    if (_loggedQuestionIndices.contains(index)) {
      print('📝 题目 $index 已记录过答题日志，跳过重复记录');
      return;
    }

    // 计算答题用时
    int timeSpent = 0;
    if (_questionStartTime != null) {
      timeSpent = DateTime.now().difference(_questionStartTime!).inSeconds;
    }

    // 获取用户答案，根据题目类型处理
    dynamic userAnswerData;
    if (question.kind == 'FILL' || question.kind == 'SHORT') {
      // 填空或简答题
      userAnswerData = userAnswer;
    } else {
      // 选择题，转换为字符串
      userAnswerData = userAnswer.map((e) => e.toString()).join(',');
    }

    // 确定 source_type 和 source_id
    String sourceType = 'TRAIN';
    int sourceId = 0;
    if (paperId != null) {
      sourceType = 'PAPER';
      sourceId =
          paperId is int ? paperId! : int.tryParse(paperId.toString()) ?? 0;
    }

    // 获取 cate_id
    final cateId = int.tryParse(question.cateId) ?? 0;

    print(
        '📝 准备记录答题日志: questionId=${question.id}, cateId=$cateId, isCorrect=$isCorrect, timeSpent=$timeSpent');

    // 调用答题日志接口
    _addQuestionLog(
      questionId: int.tryParse(question.id) ?? 0,
      cateId: cateId,
      userAnswer: userAnswerData,
      isCorrect: isCorrect ? 1 : 0,
      timeSpent: timeSpent,
      sourceType: sourceType,
      sourceId: sourceId,
    );

    // 标记已记录
    _loggedQuestionIndices.add(index);
    print('📝 题目 $index 答题日志已记录');
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // 提交当前题答案（多选题手动提交）
  void submitCurrentQuestion() {
    if (pageMode.value != 'TRAINING') return;

    final currentIndex = currentQuestionIndex.value;
    final userAnswer = userAnswers[currentIndex];

    if (userAnswer == null || userAnswer.isEmpty) {
      SnackbarUtils.showInfo('请先选择答案');
      return;
    }

    _checkAnswer(currentIndex, userAnswer);
    showExplanation.value = true;
  }

  // 切换解析显示状态
  void toggleExplanation() {
    showExplanation.value = !showExplanation.value;
  }

  // 提交答案（主要是多选题需要确认，单选题通常自动下一题或直接显示结果，这里简单实现为显示解析）
  void submitAnswer() {
    showExplanation.value = true;
  }

  // 下一题
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 最后一题
      SnackbarUtils.showInfo('已经是最后一题了');
    }
  }

  // 上一题
  void previousQuestion() {
    if (pageMode.value == 'EXAM') {
      // 考试模式禁止回退? 用户需 "顺序答题（默认只能下一题）"
      // 但通常考试系统也允许检查上一题.. 不过根据用户描述 "顺序答题", 暂且禁止或者提示
      SnackbarUtils.showInfo('考试模式下只能按顺序答题');
      return;
    }

    if (currentQuestionIndex.value > 0) {
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      SnackbarUtils.showInfo('已经是第一题了');
    }
  }

  // 保存考试进度
  void _saveExamProgress() {
    if (pageMode.value == 'EXAM' && paperId != null) {
      final progressData = {
        'userAnswers': userAnswers,
        'remainingSeconds': remainingSeconds.value,
        'currentQuestionIndex': currentQuestionIndex.value,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _box.write('exam_progress_$paperId', progressData);
    }
  }

  // 切换详情/列表视图 (看题模式)
  void toggleDetailView() {
    isDetailView.value = !isDetailView.value;
  }

  // 从列表进入详情视图
  // @param index 索引值
  // @return 无
  void enterDetailView(int index) {
    currentQuestionIndex.value = index;
    isDetailView.value = true;
    // 确保 PageView 跳转到对应页
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
  }

  // 更新当前索引（由 PageView 滑动触发）
  void updateCurrentIndex(int index) {
    currentQuestionIndex.value = index;

    // 记录新题目的开始时间
    _questionStartTime = DateTime.now();
    print('⏱️ 题目 $index 开始时间已更新: $_questionStartTime');

    if (pageMode.value == 'VIEW') {
      // 背题模式：切换题目时隐藏解析，等待用户点击选项后显示
      showExplanation.value = false;
    } else {
      // 答题模式：始终隐藏解析（答题时不显示答案）
      showExplanation.value = false;
    }
  }

  // 调用答题日志接口
  Future<void> _addQuestionLog({
    required int questionId,
    required int cateId,
    required dynamic userAnswer,
    required int isCorrect,
    required int timeSpent,
    String sourceType = 'TRAIN',
    int sourceId = 0,
  }) async {
    try {
      print('🌐 正在调用答题日志接口...');
      print(
          '📡 请求参数: question_id=$questionId, cate_id=$cateId, user_answer=$userAnswer, is_correct=$isCorrect, time_spent=$timeSpent, source_type=$sourceType, source_id=$sourceId');

      final response = await _examRepository.addQuestionLog({
        'question_id': questionId,
        'cate_id': cateId,
        'user_answer': userAnswer,
        'is_correct': isCorrect,
        'time_spent': timeSpent,
        'source_type': sourceType,
        'source_id': sourceId,
      });

      print('✅ 答题日志接口调用成功: $response');
      print('✅ response.data: ${response.data}');
      print('✅ response.code: ${response.code}');
      print('✅ response.message: ${response.message}');
    } catch (e, stackTrace) {
      print('❌ 记录答题日志失败: $e');
      print('📋 错误堆栈: $stackTrace');
      // 不影响正常答题流程，只打印日志
    }
  }

  // 跳转到指定题目
  void jumpToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      pageController.jumpToPage(index);
      // updateCurrentIndex 会被 PageView 触发，所以这里不需要手动调用
    }
  }

  // (底部弹出 (底部弹出)
  void showAnswerCard() {
    final context = Get.context;
    if (context == null) return;

    Get.bottomSheet(
      _buildAnswerCardContent(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  // 答题卡内容
  Widget _buildAnswerCardContent() {
    final isDark = isDarkMode.value;

    return Obx(() => Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(ScreenAdapter.radius(32))),
          ),
          padding: EdgeInsets.all(ScreenAdapter.width(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖动条
              Container(
                width: ScreenAdapter.width(120),
                height: ScreenAdapter.height(8),
                margin: EdgeInsets.only(bottom: ScreenAdapter.height(30)),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF555555) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(ScreenAdapter.radius(4)),
                ),
              ),

              // 顶部标题和关闭按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: ScreenAdapter.width(48)), // 占位，让标题居中
                  Text(
                    '答题卡',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(46),
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close,
                        color: isDark ? Colors.white : Colors.black87,
                        size: ScreenAdapter.width(60)),
                  ),
                ],
              ),

              // 题目网格（每行5个，最多显示6行题目编号）
              SizedBox(
                height: _calcGridHeight(),
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 根据可用宽度精确计算每行高度
                      final crossAxisCount = 5;
                      final spacing = 10.0;
                      final crossAxisSpacing = 12.0;
                      final aspectRatio = 1.15;
                      final availableWidth = constraints.maxWidth;
                      final itemWidth = (availableWidth -
                              crossAxisSpacing * (crossAxisCount - 1)) /
                          crossAxisCount;
                      final itemHeight = itemWidth / aspectRatio;
                      final rowHeight = itemHeight + spacing;

                      return GridView.builder(
                        shrinkWrap: questions.length <= 30,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: crossAxisSpacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: aspectRatio,
                          mainAxisExtent: itemHeight,
                        ),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          bool isCurrent = currentQuestionIndex.value == index;
                          bool isAnswered = userAnswers.containsKey(index) &&
                              (userAnswers[index]?.isNotEmpty ?? false);
                          bool? isCorrect = answerResults[index];
                          final question = questions[index];
                          final questionStatus = question.questionStatus;

                          Color bgColor =
                              isDark ? const Color(0xFF3D3D3D) : Colors.white;
                          Color borderColor = isDark
                              ? const Color(0xFF555555)
                              : Colors.grey[300]!;
                          Color textColor =
                              isDark ? Colors.white70 : Colors.black87;

                          // 优先根据 questionStatus 判断颜色
                          if (questionStatus == 2) {
                            // 已做正确
                            bgColor = const Color(0xFF52C41A);
                            borderColor = bgColor;
                            textColor = Colors.white;
                          } else if (questionStatus == 3) {
                            // 已做错误
                            bgColor = const Color(0xFFF5222D);
                            borderColor = bgColor;
                            textColor = Colors.white;
                          } else if (isAnswered) {
                            // 已作答但没有 questionStatus 或 questionStatus 为未做
                            if (pageMode.value == 'TRAINING' &&
                                isCorrect != null &&
                                showExplanation.value) {
                              // 练习模式已查看结果，显示对错颜色（绿/红）
                              bgColor = isCorrect
                                  ? const Color(0xFF52C41A)
                                  : const Color(0xFFF5222D);
                              borderColor = bgColor;
                              textColor = Colors.white;
                            } else {
                              // 已作答但未查看结果，显示蓝底白字（实心）
                              bgColor = const Color(0xFF1890FF);
                              borderColor = bgColor;
                              textColor = Colors.white;
                            }
                          } else if (isCurrent) {
                            // 当前题目但未作答，显示蓝色边框+原底蓝字（空心，与已作答区分）
                            borderColor = const Color(0xFF1890FF);
                            textColor = const Color(0xFF1890FF);
                          }

                          return GestureDetector(
                            onTap: () {
                              jumpToQuestion(index);
                              Get.back();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: borderColor,
                                    width: isCurrent ? 1.5 : 1.0),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(32),
                                  color: textColor,
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // 提交按钮 (考试模式和练习模式都显示)
              if (pageMode.value == 'EXAM' || pageMode.value == 'TRAINING') ...[
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: ScreenAdapter.height(20)),
                      SizedBox(
                        width: double.infinity,
                        height: ScreenAdapter.height(128),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            submitExam();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1890FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ScreenAdapter.radius(60)),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            '提交',
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(44),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  // 计算网格高度：最多显示6行，不满6行按实际行数（无空白）
  double _calcGridHeight() {
    // 基于屏幕宽度计算每行实际高度（需扣除 Container 的 padding）
    final screenWidth = Get.width - ScreenAdapter.width(32) * 2;
    const crossAxisCount = 5;
    const crossAxisSpacing = 12.0;
    const spacing = 10.0;
    const aspectRatio = 1.15;

    final itemWidth = (screenWidth - crossAxisSpacing * (crossAxisCount - 1)) /
        crossAxisCount;
    final itemHeight = itemWidth / aspectRatio;
    final rowHeight = itemHeight + spacing;

    final totalRows = (questions.length / crossAxisCount).ceil();
    final displayRows = totalRows.clamp(1, 6);
    return rowHeight * displayRows;
  }

  // 构建图例项
  Widget _buildLegendItem(bool isDark, Color color, String label,
      {bool hasBorder = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenAdapter.width(28),
          height: ScreenAdapter.width(28),
          decoration: BoxDecoration(
            color: hasBorder ? Colors.white : color,
            shape: BoxShape.circle,
            border: hasBorder
                ? Border.all(color: Colors.grey[400]!, width: 1.5)
                : null,
          ),
        ),
        SizedBox(width: ScreenAdapter.width(8)),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(24),
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  // 切换收藏状态（调用 API）
  Future<void> toggleFavorite() async {
    final currentIndex = currentQuestionIndex.value;
    if (currentIndex < 0 || currentIndex >= questions.length) return;
    if (isCollecting.value) return; // 防止重复点击

    final question = questions[currentIndex];
    final questionId = question.id;

    // ⚠️ 关键修复：只依赖 favoriteQuestions map 判断当前状态
    // 不再依赖 question.isCollected（因为收藏模式加载时硬编码为 true，不会随操作更新）
    final isCurrentlyFav = favoriteQuestions[currentIndex] ?? false;

    print(
        '🔖 切换收藏: questionId=$questionId (${questionId.runtimeType}), 当前状态=$isCurrentlyFav -> ${!isCurrentlyFav}, pageType=$pageType');

    isCollecting.value = true; // 开始加载
    try {
      String apiUrl;
      if (isCurrentlyFav) {
        // 取消收藏
        apiUrl = 'question/collectCancel';
      } else {
        // 添加收藏
        apiUrl = 'question/collectAdd';
      }

      // 确保 question_id 为整数
      // 如果 questionId 不是整数，转换为 0
      // 这里假设 API 接口需要整数参数
      final intQuestionId = int.tryParse(questionId.toString()) ?? 0;
      print('🔖 调用API: $apiUrl, question_id=$intQuestionId');

      final response = await ApiClient.to.postExam(
        apiUrl,
        data: {'question_id': intQuestionId},
      );

      print('🔖 收藏API响应 status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200 && response.data is Map) {
        final code = response.data['code'];
        if (code == 1 || code == '1') {
          // 成功：更新收藏状态 map（UI 从此 map 读取）
          final newFavState = !isCurrentlyFav;
          favoriteQuestions[currentIndex] = newFavState;

          print('🔖 收藏操作成功: ${newFavState ? "已添加到收藏" : "已取消收藏"}');
        } else {
          print('⚠️ 收藏API返回错误: code=$code, msg=${response.data['msg']}');
        }
      } else {
        print('⚠️ 收藏API请求失败: statusCode=${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('收藏操作出错: $e');
      print('堆栈: $stackTrace');
    } finally {
      isCollecting.value = false; // 结束加载
    }
  }

  // 从题目数据初始化收藏状态
  // 从题目数据初始化收藏状态
  void _initFavoriteStatus() {
    favoriteQuestions.clear();
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].isCollected) {
        favoriteQuestions[i] = true;
      }
    }

    final collectedCount = favoriteQuestions.values.where((v) => v).length;
    print('🔖 收藏状态初始化完成: ${questions.length} 题中 $collectedCount 题已收藏');

    // 恢复用户之前的答题记录
    _restoreUserAnswers();

    // 记录第一题的开始时间
    if (questions.isNotEmpty) {
      _questionStartTime = DateTime.now();
      print('⏱️ 第一题开始时间已记录');
    }
  }

  // 恢复用户之前的答题记录（从 Question.userAnswer 字段）
  void _restoreUserAnswers() {
    int restoredCount = 0;
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      if (question.userAnswer != null && question.userAnswer!.isNotEmpty) {
        userAnswers[i] = List<int>.from(question.userAnswer!);
        restoredCount++;

        // 如果有用户答案，同时恢复答题结果（基于 questionStatus）
        if (question.questionStatus == 2) {
          answerResults[i] = true; // 正确
        } else if (question.questionStatus == 3) {
          answerResults[i] = false; // 错误
        }
      }
    }
    if (restoredCount > 0) {
      print('✅ 恢复用户答题记录: $restoredCount/${questions.length} 题已恢复答案');
    } else {
      print('ℹ️ 无历史答题记录需要恢复');
    }
  }

  // 查找第一个未做过的题目索引 (question_status == 1)
  void _jumpToFirstUndoneQuestion() {
    if (questions.isEmpty) return;

    int targetIndex = 0; // 默认第一题
    for (int i = 0; i < questions.length; i++) {
      final qs = questions[i].questionStatus;
      // question_status == 1 表示未做，找到第一个这样的题目
      if (qs == 1) {
        targetIndex = i;
        print('🎯 找到第一个未做题 索引=$i');
        break;
      }
    }

    // 如果所有题都做过了 (没有找到 question_status == 1)，则留在第一题
    currentQuestionIndex.value = targetIndex;
    print('🎯 设置初始题目索引: $targetIndex');

    // 使用 WidgetsBinding 确保在第一帧后跳转，更可靠
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(targetIndex);
        print('🎯 PageView 已跳转到索引: $targetIndex');
      } else {
        print('⚠️ pageController 还没有客户端，无法跳转');
        // 如果还没有客户端，再尝试一次
        Future.delayed(const Duration(milliseconds: 100), () {
          if (pageController.hasClients) {
            pageController.jumpToPage(targetIndex);
            print('🎯 第二次尝试：PageView 已跳转到索引: $targetIndex');
          }
        });
      }
    });
  }

  // 处理返回按钮退出逻辑
  Future<bool> onWillPop() async {
    // 防止屏幕边缘滑动导致的误触，统一提示
    return await showExitDialog(message: '确定退出吗？');
  }

  // 显示退出确认对话框 (使用 Get.dialog 无动画)
  Future<bool> showExitDialog({String message = '确定退出吗？'}) async {
    final completer = Completer<bool>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '退出提示',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        completer.complete(false);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '取消',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        completer.complete(true);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A9EF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '确定',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      transitionDuration: Duration.zero,
    );

    return completer.future;
  }
}
