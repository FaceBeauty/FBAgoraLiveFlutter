import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mt_plugin/components/mt_beauty_panel/view.dart';

import '../controllers/camera_controller.dart';
import 'dart:ui' as ui;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

///相机View
class CameraView extends GetView<CameraController> {

  @override
  Widget build(BuildContext context) {
    print('CameraView controller: $controller');
    return Scaffold(
      body: Stack(
        children: [
          MtBeautyPanelContainer(),
          // 原生传过来的视频帧展示
          // Obx(() {
          //   final image = controller.frameImage;
          //   if (image == null) return SizedBox.shrink();
          //
          //   const maxWidth = 180.0;
          //   final imageRatio = image.height / image.width;
          //   final displayHeight = maxWidth * imageRatio;
          //
          //   return Positioned(
          //     top: 40,
          //     left: 20,
          //     child: SizedBox(
          //       width: maxWidth,
          //       height: displayHeight,
          //       child: CustomPaint(
          //         painter: _ImagePainter(image),
          //       ),
          //     ),
          //   );
          // }),
          // 右上角远端视频视图
          Obx(() {
            if (controller.remoteUid.isEmpty) return SizedBox.shrink();

            // 创建远端视频控制器
            final remoteController = VideoViewController.remote(
              rtcEngine: controller.engine,
              canvas: VideoCanvas(
                uid: controller.remoteUid.first,
                renderMode: RenderModeType.renderModeFit,
              ),
              connection: RtcConnection(channelId: 'test'),
            );
            print("Remote UID: ${controller.remoteUid}");

            return Positioned(
              top: 16,
              right: 16,
              width: 120,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800], // 设置背景色
                  borderRadius: BorderRadius.circular(8), // 圆角
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8), // 确保视频也有圆角
                  child: AgoraVideoView(controller: remoteController),
                ),
              ),
            );
          }),
          Positioned(
            top: 30,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                print("加入频道点击1");
                controller.joinChannel();
              },
              child: const Text("加入频道"),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                print("离开频道点击1");
                controller.leaveChannel();
              },
              child: const Text("离开频道"),
            ),
          ),
        ],
      ),
    );
  }

}
class _ImagePainter extends CustomPainter {
  final ui.Image image;
  _ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final scale = (size.width / imageWidth).clamp(0.0, 1.0);

    final drawWidth = imageWidth * scale;
    final drawHeight = imageHeight * scale;
// 旋转中心设为左上角，先平移画布到右上角，再逆时针旋转90度
    canvas.save();
    canvas.translate(drawWidth, 0);
    canvas.rotate(90 * 3.1415926 / 180);
    final src = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    final dst = Rect.fromLTWH(0, 0, drawWidth, drawHeight);

    canvas.drawImageRect(image, src, dst, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ImagePainter oldDelegate) => oldDelegate.image != image;
}