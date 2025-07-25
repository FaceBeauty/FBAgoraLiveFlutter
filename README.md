简体中文 | [English](README_EN.md) 

## FaceBeauty

### Flutter平台 快速集成

#### Flutter插件

GitHub仓库

```apl
https://github.com/FaceBeauty/FBLiveFlutter
```

#### Flutter插件(声网)

GitHub仓库

```
https://github.com/FaceBeauty/FBAgoraLiveFlutter
```

#### Flutter插件集成步骤:

1. 下载虹图SDK包

   - Android：


   ​	将FaceBeauty.arr文件分别放到`mt_plugin/android/libs`文件夹下和`mtcamera/android/app/libs`文件夹下。将jinLibs文件夹放到`/mt_plugin/android/src/main`文件夹下面。

   - iOS：

     将FaceBeauty.framwork文件放到`mt_plugin/ios/Vendored`文件夹下。

2. 联系虹图商务获取证书文件和资源包。

3. 将资源包中的文件放到对应的文件夹下

   - Android：

     将资源文件放到`mt_plugin/android/src/main/assets/fbeffect`文件夹下。

   - iOS：

     将资源文件FaceBeauty.bundle放到`mt_plugin/ios/Vendored`文件夹下。

4. 在Android Studio中打开示例项目FaceBeautyFultter

5. 在pubspec.yaml所处的文件夹下执行flutter命令`flutter pub get`获取依赖。

6. 将Android和iOS的包名和应用名替换成用户对应的包名和应用名。

7. 添加key

   - Android：

     打开`mt_plugin/android/src/main/kotlin/com/toivan/mtcamera/mt_plugin/MtPlugin.kt`文件，将`<YOUR_APP_ID>`替换成你的App ID。

     ```
     FBEffect.shareInstance().initFaceBeauty(it, "<YOUR_APP_ID>", object : FBEffect.InitCallback {
                             override fun onInitSuccess() = Unit
                             override fun onInitFailure() = Unit
                         })
     ```

   - iOS：

     打开`mcamera/ios/Runner/IOSFlutterView.m`文件，将`<YOUR_APP_ID>`替换成你的App ID。App ID需要联系虹图商务获取

     ```
     [[FaceBeauty shareInstance] initFaceBeauty:@"<YOUR_APP_ID>" withDelegate:self];
     ```

8. 连接Android或iOS真机（非模拟器），运行项目。

#### Flutter插件(声网)集成步骤

1. 声网RTC文档：https://github.com/AgoraIO-Extensions/Agora-Flutter-SDK/blob/main/example/lib/examples/advanced/push_video_frame/push_video_frame.dart
2. 快速跑通
   - 声网自行创建appid,token,channel,两台设备同时加入调试
   - 声网的webDemo，可快速查看房间推流，https://webdemo.agora.io/basicVideoCall/index.html
3. 添加声网的APPID、Token、channel、uID
   - 在mtcamera-->lib-->app-->modules-->camera-->controllers-->camera_controller.dart（可通过搜索todo fb定位）
   - Agora RTC 推流服务端

#### Agora RTC 推流服务端关键流程说明

1.  Flutter 初始化 Agora（camera_controller.dart）

   ```
   final _engine = createAgoraRtcEngine();
   await _engine.initialize(RtcEngineContext(appId: ...));
   await _engine.setClientRole(...);
   await _engine.setExternalVideoSource(enabled: true, useTexture: false);
   await _engine.enableVideo();
   await _engine.startPreview();
   ```

2. Flutter 通知原生开始采集推流

3.  iOS 原生层初始化采集逻辑（IOSFlutterView.swift）

   - ```
     func startPushToAgora() {
     
     faceBeauty.startCapture { imageBuffer in
     
     let bytes = bufferToBGRA(imageBuffer)
     
     sendToFlutter(bytes: bytes, width: ..., height: ..., stride: ...)
     
     }
     
     }
     ```

4.  Flutter 层接收原生视频帧并推送给 Agora

   ```
   await engine.getMediaEngine().pushVideoFrame(
   ExternalVideoFrame(
   type: VideoBufferType.videoBufferRawData,
   format: VideoPixelFormat.videoPixelBgra,
   buffer: bytes,
   stride: stride,
   height: height,
   rotation: 90,
   timestamp: DateTime.now().millisecondsSinceEpoch,
   ),
   );
   ```

5. mtcamera\lib\app\modules\camera\views\camera_view.dart(右上角远端画面)