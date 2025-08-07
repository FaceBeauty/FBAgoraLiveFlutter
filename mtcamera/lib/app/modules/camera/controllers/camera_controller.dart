import 'dart:io';

import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class CameraController extends GetxController {
  late final RtcEngine engine;

  final isJoined = false.obs;
  final remoteUid = <int>[].obs;
  final MethodChannel _channel = const MethodChannel("beauty_plugin");

// 新增：存储当前帧图像
  final _frameImage = Rxn<ui.Image>();
  ui.Image? get frameImage => _frameImage.value;

  @override
  void onInit() {
    super.onInit();
    initAgora();
    print("🎯 进入相机页面");
  }

  void checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.baidu.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ 网络正常');
      } else {
        print('❌ 无网络连接');
      }
    } catch (e) {
      print('❌ 网络错误: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
    _channel.setMethodCallHandler(_handleNativeMethod);
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }
  Future<void> _dispose() async {
    await engine.leaveChannel();
    await engine.release();
  }

  Future<void> initAgora() async  {
  engine = createAgoraRtcEngine();
  print("🎯 Agora engine 初始化: $engine");
  await engine.initialize(
    //todo fb 声网的appid
  const RtcEngineContext(appId: "********"),
  );
  await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
  await engine.setLogFilter(LogFilterType.logFilterError);

  await engine.getMediaEngine().setExternalVideoSource(
  enabled: true,
  useTexture: false,
  );
  await engine.enableVideo();
  await engine.startPreview(sourceType: VideoSourceType.videoSourceCustom);

  print("Flutter 中 engine 对象地址: $engine");
  engine.registerEventHandler(RtcEngineEventHandler(
  onError: (ErrorCodeType err, String msg) {
  print('[onError] err: $err, msg: $msg');
  },
  onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
  print('[onJoinChannelSuccess] connection: ${connection.toJson()} elapsed: $elapsed');
  isJoined.value = true;
  // 成功加入频道后再通知 native 开始推流
  startNativePush();
  },
  onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
  print('[onUserJoined] connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed');
  remoteUid.add(rUid);
  print("Remote UID: ${remoteUid}");
  },
  onUserOffline: (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
  print('[onUserOffline] connection: ${connection.toJson()}  rUid: $rUid reason: $reason');
  remoteUid.remove(rUid);
  },
  onLeaveChannel: (RtcConnection connection, RtcStats stats) {
  print('[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}');
  isJoined.value = false;
  stopNativePush();
  remoteUid.clear();
  },
  ));
  print('✅ Agora 初始化完成');
  //todo fb 声网的appid
  await _channel.invokeMethod("setEngine", "*******");
}
  Future<void> joinChannel() async {
    print("加入频道点击2");
    try {
      await engine.joinChannel(
        //todo fb 声网
        token: "**********",
        // token: "null",
        channelId: "****",
        uid: 10086,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      print("✅ joinChannel 调用成功");
    } catch (e, stack) {
      print("❌ joinChannel 调用失败: $e\n$stack");
    }
  }

  Future<void> leaveChannel() async {
    await engine.leaveChannel();
  }

  void startNativePush() {
    _channel.invokeMethod("startAgoraPush").catchError((e) {
      print("❌ 调用 startAgoraPush 失败: $e");
    });
  }
  void stopNativePush() {
    _channel.invokeMethod("stopAgoraPush").catchError((e) {
      print("❌ 调用 StopAgoraPush 失败: $e");
    });
  }

  Future<void> _handleNativeMethod(MethodCall call) async {
    if (call.method == "onFrame") {
      try {
        final Map<dynamic, dynamic> args = call.arguments;
        Uint8List bytes = args['bytes'];
        int width = args['width'];
        int height = args['height'];
        int stride = args['stride'];
        // int format = args['format'];

        // ⚠️ 校验内存长度
        if (bytes.length != stride * height) {
          print("❌ 内存大小不合法: ${bytes.length} vs ${stride * height}");
          return;
        }
        // print("开始 pushVideoFrame: $width x $height, stride: $stride, bytes: ${bytes.length}");
// BGRA 格式解码 为了看传过来的图像帧
//         ui.decodeImageFromPixels(
//           bytes,
//           width,
//           height,
//           ui.PixelFormat.bgra8888,
//               (ui.Image img) {
//             _frameImage.value = img;
//           },
//         );
//         final byteData =
//         await _frameImage.value?.toByteData(format: ui.ImageByteFormat.rawStraightRgba);

        await engine.getMediaEngine().pushVideoFrame(
          frame: ExternalVideoFrame(
            type: VideoBufferType.videoBufferRawData,
            format: VideoPixelFormat.videoPixelBgra,
            // buffer: bytes.buffer.asUint8List(),
            buffer: bytes,
            stride: width,
            height: height,
            rotation: 180, // 旋转90度
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );

      } catch (e, stack) {
        print("❌ pushVideoFrame 失败: $e");
        print("Stack: $stack");
      }

    }
  }


  @override
  void onClose() {}


}
