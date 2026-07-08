import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../services/snackbar_utils.dart';
import '../../../routes/app_pages.dart';

class DetailsController extends GetxController {
  // 当前选中的Tab索引
  final currentTabIndex = 0.obs;

  // 课程详情数据
  final RxMap<String, dynamic> courseDetail = <String, dynamic>{}.obs;

  // 课程目录列表 (来自 items 字段)
  final RxList<dynamic> courseItems = <dynamic>[].obs;

  // 加载状态
  final RxBool isLoading = false.obs;

  // 视频播放器相关
  VideoPlayerController? _videoPlayerController;
  final Rx<ChewieController?> chewieController = Rx<ChewieController?>(null);

  // 当前播放的视频信息
  final RxString currentVideoUrl = ''.obs;
  final RxString currentVideoTitle = ''.obs;
  final RxBool isVideoPlaying = false.obs;
  final RxInt currentPlayingLessonId = 0.obs;

  // 播放速度选项
  final List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  final RxDouble currentSpeed = 1.0.obs;

  // 当前播放的课时信息（用于保存进度）
  int? _currentLessonId;
  DateTime? _playStartTime;
  bool _isHandlingCompletion = false;

  @override
  void onInit() {
    super.onInit();
    // 获取传入的课程ID
    if (Get.arguments != null) {
      final dynamic args = Get.arguments;
      int? courseId;
      if (args is Map) {
        courseId = int.tryParse(args['id']?.toString() ?? '');
      } else if (args is int) {
        courseId = args;
      } else if (args is String) {
        courseId = int.tryParse(args);
      }

      if (courseId != null) {
        getCourseDetail(courseId);
      } else {
        SnackbarUtils.showError("无效的课程ID");
      }
    }
  }

  // 获取课程详情
  Future<void> getCourseDetail(int id) async {
    isLoading.value = true;
    try {
      final response = await ApiClient.to.get(
        'addons/exam/coures/detail',
        queryParameters: {'id': id},
        options: dio.Options(
          headers: {
            'token': Get.isRegistered<AuthService>()
                ? AuthService.to.token.value ?? ''
                : '',
          },
        ),
      );

      if (response.data != null && response.data['code'] == 1) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          courseDetail.value = data;

          // 处理目录数据 (items)
          if (data['items'] is List) {
            courseItems.value = data['items'];
          }

          print("Success: Course details loaded - ${courseDetail['title']}");
        }
      } else {
        SnackbarUtils.showError(response.data['msg'] ?? "获取详情失败");
      }
    } catch (e) {
      print("Error: Failed to load course details - $e");
      if (e is dio.DioException) {
        SnackbarUtils.showError("服务器错误 ${e.response?.statusCode}");
      } else {
        SnackbarUtils.showError("获取课程详情失败");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 切换Tab
  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  // 播放指定课程项的视频（在当前页面播放，不跳转页面）
  void playCourseItem(dynamic item) {
    final String? videoUrl =
        item['url']?.toString() ?? item['video_url']?.toString();
    final String title = item['title']?.toString() ?? '课程视频';
    final lessonId = int.tryParse(item['id']?.toString() ?? '');

    // 获取上次播放进度
    final progress = item['progress'];
    final lastPosition =
        int.tryParse(progress?['last_position']?.toString() ?? '0') ?? 0;
    final duration =
        int.tryParse(progress?['duration']?.toString() ?? '0') ?? 0;
    final initialPosition =
        duration > 0 && lastPosition >= duration - 3 ? 0 : lastPosition;

    // 如果正在播放其他视频，先保存进度再停止
    if (chewieController.value != null) {
      _saveCurrentProgress();
      _disposeVideoPlayers();
    }

    // 记录当前课时信息
    _currentLessonId = lessonId;
    currentPlayingLessonId.value = lessonId ?? 0;
    _playStartTime = DateTime.now();

    if (videoUrl != null && videoUrl.isNotEmpty) {
      // 在封面区域内播放视频，传入上次播放进度
      playVideoInCover(videoUrl, title, initialPosition);
    } else {
      SnackbarUtils.showInfo('该课程暂无视视频 $title');
    }
  }

  // 在封面区域内播放视频
  Future<void> playVideoInCover(String url, String title,
      [int initialPosition = 0]) async {
    // 如果是同一个视频，直接播放
    if (currentVideoUrl.value == url && _videoPlayerController != null) {
      await _videoPlayerController!.play();
      isVideoPlaying.value = true;
      return;
    }

    // 释放旧的播放器资源
    _disposeVideoPlayers();

    // 记录当前视频信息
    currentVideoUrl.value = url;
    currentVideoTitle.value = title;

    try {
      // 创建新的视频控制器
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(ApiClient.replaceUri(url)),
      );

      await _videoPlayerController!.initialize();

      // 如果有上次播放进度，跳转到该位置
      if (initialPosition > 0) {
        await _videoPlayerController!
            .seekTo(Duration(seconds: initialPosition));
      }

      // 创建 Chewie 控制器
      final newChewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio.isFinite &&
                _videoPlayerController!.value.aspectRatio > 0
            ? _videoPlayerController!.value.aspectRatio
            : 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: playbackSpeeds,
        optionsTranslation: OptionsTranslation(
          playbackSpeedButtonText: '播放速度',
          subtitlesButtonText: '字幕',
          cancelButtonText: '取消',
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage ?? '播放失败',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );

      // 设置响应式的 Chewie 控制器
      chewieController.value = newChewieController;

      // 监听播放状态变化，播放完成后自动进入下一节
      final controller = _videoPlayerController!;
      controller.addListener(() {
        final value = controller.value;
        isVideoPlaying.value = value.isPlaying;
        if (value.isInitialized &&
            !value.isPlaying &&
            value.duration > Duration.zero &&
            value.position >= value.duration - const Duration(seconds: 1)) {
          _handleVideoCompleted();
        }
      });

      isVideoPlaying.value = true;
    } catch (e) {
      print("Error: Failed to initialize video player - $e");
      SnackbarUtils.showInfo('该视频暂时无法播放，请稍后重试');
      _disposeVideoPlayers();
    }
  }

  // 释放视频播放器资源
  void _disposeVideoPlayers() {
    chewieController.value?.dispose();
    _videoPlayerController?.dispose();
    chewieController.value = null;
    _videoPlayerController = null;
    isVideoPlaying.value = false;
  }

  Future<void> _handleVideoCompleted() async {
    if (_isHandlingCompletion) return;

    _isHandlingCompletion = true;
    await _saveCurrentProgress();

    final nextItem = _getNextPlayableItem();
    if (nextItem != null) {
      _disposeVideoPlayers();
      playCourseItem(nextItem);
    } else {
      isVideoPlaying.value = false;
      SnackbarUtils.showInfo('已播放到最后一节');
    }

    _isHandlingCompletion = false;
  }

  dynamic _getNextPlayableItem() {
    final items = _flattenPlayableItems(courseItems);
    if (items.isEmpty) return null;

    final currentIndex = items.indexWhere((item) {
      final itemId = int.tryParse(item['id']?.toString() ?? '');
      final itemUrl = item['url']?.toString() ?? item['video_url']?.toString();
      return (_currentLessonId != null && itemId == _currentLessonId) ||
          (currentVideoUrl.value.isNotEmpty &&
              itemUrl == currentVideoUrl.value);
    });

    if (currentIndex >= 0 && currentIndex < items.length - 1) {
      return items[currentIndex + 1];
    }
    return null;
  }

  List<dynamic> _flattenPlayableItems(List<dynamic> items) {
    final result = <dynamic>[];

    for (final item in items) {
      if (item is! Map) continue;

      final videoUrl = item['url']?.toString() ?? item['video_url']?.toString();
      if (videoUrl != null && videoUrl.isNotEmpty) {
        result.add(item);
      }

      final children = item['childlist'] ?? item['children'];
      if (children is List) {
        result.addAll(_flattenPlayableItems(children));
      }
    }

    return result;
  }

  // 保存当前播放进度到服务器
  Future<void> _saveCurrentProgress() async {
    if (_currentLessonId == null || _videoPlayerController == null) return;

    final courseId = courseDetail['id'];
    if (courseId == null) return;

    try {
      final position = _videoPlayerController!.value.position.inSeconds;
      final duration = _videoPlayerController!.value.duration.inSeconds;

      // 计算本次观看时长（秒）
      int watchDuration = 0;
      if (_playStartTime != null) {
        watchDuration = DateTime.now().difference(_playStartTime!).inSeconds;
      }

      await ApiClient.to.exam(
        'coures/saveProgress',
        method: 'POST',
        data: {
          'course_id': courseId.toString(),
          'lesson_id': _currentLessonId.toString(),
          'last_position': position,
          if (duration > 0) 'duration': duration,
          if (watchDuration > 0) 'watch_duration': watchDuration,
        },
      );

      print("Progress saved: lesson=$_currentLessonId, pos=$position");
    } catch (e) {
      print("Error: Failed to save progress - $e");
    }
  }

  // 切换播放/暂停
  void togglePlayPause() {
    if (_videoPlayerController != null) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      } else {
        _videoPlayerController!.play();
      }
    }
  }

  // 设置播放速度
  void setPlaybackSpeed(double speed) {
    currentSpeed.value = speed;
    _videoPlayerController?.setPlaybackSpeed(speed);
    update();
  }

  // 模拟开始学习操作
  void startLearning(dynamic item) {
    playCourseItem(item);
  }

  @override
  void onClose() {
    _saveCurrentProgress();
    _disposeVideoPlayers();
    super.onClose();
  }
}
