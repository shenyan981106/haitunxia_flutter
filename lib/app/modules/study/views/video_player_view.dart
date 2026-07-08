import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import '../../../services/screenAdapter.dart';
import '../controllers/video_player_controller.dart';

class VideoPlayerView extends GetView<StudyVideoPlayerController> {
  const VideoPlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isVideoInitialized.value) {
          // 加载中状态
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A86FF)),
                ),
                SizedBox(height: ScreenAdapter.height(20)),
                Text(
                  '视频加载中...',
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(30),
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // 视频播放区域
            _buildVideoArea(),

            // 底部信息区域（可滚动）
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenAdapter.width(24)),
                    topRight: Radius.circular(ScreenAdapter.width(24)),
                  ),
                ),
                child: _buildInfoArea(),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 视频播放器区域
  Widget _buildVideoArea() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Chewie 播放器
            Center(
              child: AspectRatio(
                aspectRatio:
                    controller.videoPlayerController!.value.aspectRatio,
                child: Chewie(controller: controller.chewieController!),
              ),
            ),

            // 返回按钮（覆盖在播放器上方）
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(16),
                    vertical: ScreenAdapter.height(8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(ScreenAdapter.width(8)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black38,
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: ScreenAdapter.fontSize(36),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(16)),
                      Expanded(
                        child: Text(
                          controller.currentVideoTitle.value,
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(32),
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 底部信息区域
  Widget _buildInfoArea() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenAdapter.width(36)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频标题
          Text(
            controller.currentVideoTitle.value,
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(42),
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: ScreenAdapter.height(20)),

          // 标签行
          _buildTagRow(),

          SizedBox(height: ScreenAdapter.height(24)),

          // 操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// 标签行（主讲老师等）
  Widget _buildTagRow() {
    return Row(
      children: [
        // 主讲老师标签
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenAdapter.width(16),
            vertical: ScreenAdapter.height(6),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF3D7CFF), width: 1),
            borderRadius: BorderRadius.circular(ScreenAdapter.width(8)),
          ),
          child: Text(
            '主讲老师',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(24),
              color: Color(0xFF3D7CFF),
            ),
          ),
        ),
        SizedBox(width: ScreenAdapter.width(12)),
        // 老师名字
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenAdapter.width(16),
            vertical: ScreenAdapter.height(6),
          ),
          decoration: BoxDecoration(
            color: Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(ScreenAdapter.width(8)),
          ),
          child: Text(
            '讲师',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(24),
              color: Color(0xFF3D7CFF),
            ),
          ),
        ),
      ],
    );
  }

  /// 右侧操作按钮
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 截图/图片按钮
        _actionButton(Icons.image_outlined, '截图'),
        SizedBox(width: ScreenAdapter.width(40)),
        // 收藏按钮
        _actionButton(Icons.star_border_outlined, '收藏'),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenAdapter.width(80),
          height: ScreenAdapter.width(80),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5F5F5),
          ),
          child: Icon(
            icon,
            size: ScreenAdapter.fontSize(40),
            color: Color(0xFF666666),
          ),
        ),
        SizedBox(height: ScreenAdapter.height(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(22),
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}
