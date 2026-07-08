import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:chewie/chewie.dart';
import '../../../data/providers/api_client.dart';
import '../../../services/snackbar_utils.dart';

class StudyVideoPlayerController extends GetxController {
  // VideoPlayer 控制器
  vp.VideoPlayerController? videoPlayerController;

  // Chewie 控制器
  ChewieController? chewieController;

  // 当前播放的视频URL
  final RxString currentVideoUrl = ''.obs;

  // 当前播放的视频标题
  final RxString currentVideoTitle = ''.obs;

  // 播放器是否初始化完成
  final RxBool isVideoInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 从路由参数获取视频信息
    if (Get.arguments != null) {
      final dynamic args = Get.arguments;
      String? videoUrl;
      String title = '课程视频';

      if (args is Map) {
        videoUrl = args['url']?.toString() ?? args['video_url']?.toString();
        title = args['title']?.toString() ?? '课程视频';
      } else if (args is String) {
        videoUrl = args;
      }

      if (videoUrl != null && videoUrl.isNotEmpty) {
        initVideoPlayer(videoUrl, title);
      } else {
        SnackbarUtils.showError('该课程暂无视频');
      }
    }
  }

  // 初始化视频播放器
  Future<void> initVideoPlayer(String videoUrl, String title) async {
    currentVideoUrl.value = videoUrl;
    currentVideoTitle.value = title;
    isVideoInitialized.value = false;

    try {
      // 补全视频URL（将相对路径转换为完整URL）
      final String fullUrl = ApiClient.getFullImageUrl(videoUrl);

      // 创建 VideoPlayerController
      videoPlayerController = vp.VideoPlayerController.networkUrl(
        Uri.parse(fullUrl),
      );

      // 初始化视频播放器
      await videoPlayerController!.initialize();

      // 创建 ChewieController
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: videoPlayerController!.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Color(0xFF3A86FF),
          handleColor: Color(0xFF3A86FF),
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        showControls: true,
        showOptions: false,
        allowFullScreen: true,
        allowMuting: true,
        playbackSpeeds: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
      );

      isVideoInitialized.value = true;
    } catch (e) {
      SnackbarUtils.showError("视频加载失败");
    }
  }

  // 切换到指定视频（目录切换时调用）
  Future<void> switchVideo(String videoUrl, String title) async {
    disposeVideoPlayer();
    await initVideoPlayer(videoUrl, title);
  }

  // 释放视频播放器资源
  void disposeVideoPlayer() {
    chewieController?.dispose();
    chewieController = null;
    videoPlayerController?.dispose();
    videoPlayerController = null;
    isVideoInitialized.value = false;
  }

  @override
  void onClose() {
    disposeVideoPlayer();
    super.onClose();
  }
}
