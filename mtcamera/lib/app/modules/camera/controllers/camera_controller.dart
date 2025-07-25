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

  @override
  void onInit() {
    super.onInit();
    initAgora();
    print("🎯 进入相机页面");
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

  Future<void> initAgora() async {
    //todo fb
    engine = createAgoraRtcEngine();
    print("🎯 Agora engine 初始化: $engine");
    //todo fb 声网的APPID（声网初始化）
    await engine.initialize(
      const RtcEngineContext(appId: "****"),
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


    // 这里是传给APP的参数（声网ID）
    // await _channel.invokeMethod("setEngine", "6f7f0d1acf93495296be18ee2e272c88");
  }

  Future<void> joinChannel() async {
    print("加入频道点击2");
    try {
      await engine.joinChannel(
        //todo fb 声网的token、channelId
        token:"***",
        // token: "null",
        channelId: "**",
        uid: 20,
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
        //int format = args['format'];

        // ⚠️ 校验内存长度
        if (bytes.length != stride * height) {
          print("❌ 内存大小不合法: ${bytes.length} vs ${width * height}");
          return;
        }
        // print("开始 pushVideoFrame: $width x $height, stride: ${width * height}, bytes: ${bytes.length}");
// BGRA 格式解码 为了看传过来的图像帧
//         ui.decodeImageFromPixels(
//           bytes,
//           width,
//           height,
//           ui.PixelFormat.rgba8888,
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
            buffer: bytes,
            stride: width,
            height: height,
            rotation: 180, // 旋转180
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );

      } catch (e, stack) {
        print("❌ pushVideoFrame 失败: $e");
        print("Stack: $stack");
      }

    }
  }

}
