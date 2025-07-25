[简体中文](README.md)| English

## FaceBeauty

### Quick Integration on Flutter Platform

#### Flutter Plugin

GitHub Repository

```apl
https://github.com/FaceBeauty/FBLiveFlutter
```

#### Flutter Plugin (Agora)

GitHub Repository

```
https://github.com/FaceBeauty/FBAgoraLiveFlutter
```

#### Steps for Integrating the Flutter Plugin:

1. Download the FaceBeauty SDK package

   - Android：


   	Place the `FaceBeauty.aar` file in the `mt_plugin/android/libs` folder and the `mtcamera/android/app/libs` folder respectively. Place the `jniLibs` folder under the `/mt_plugin/android/src/main` folder.

   - iOS：

     Place the `FaceBeauty.framework` file in the `mt_plugin/ios/Vendored` folder.

2. Contact FaceBeauty's business team to obtain the certificate file and resource package.

3. Place the files in the resource package in the corresponding folders.

   - Android：

     Place the resource files in the `mt_plugin/android/src/main/assets/fbeffect` folder.

   - iOS：

     Place the resource file `FaceBeauty.bundle` in the `mt_plugin/ios/Vendored` folder.

4. Open the sample project `FaceBeautyFlutter` in Android Studio.

5. Execute the Flutter command `flutter pub get` in the folder where `pubspec.yaml` is located to get the dependencies.

6. Replace the Android and iOS package names and app names with the corresponding ones of the user.

7. Add the key.

   - Android：

     Open the `mt_plugin/android/src/main/kotlin/com/toivan/mtcamera/mt_plugin/MtPlugin.kt` file and replace `<YOUR_APP_ID>` with your App ID.

     ```
     FBEffect.shareInstance().initFaceBeauty(it, "<YOUR_APP_ID>", object : FBEffect.InitCallback {
                             override fun onInitSuccess() = Unit
                             override fun onInitFailure() = Unit
                         })
     ```

   - iOS：

     Open the `mcamera/ios/Runner/IOSFlutterView.m` file and replace `<YOUR_APP_ID>` with your App ID. The App ID needs to be obtained by contacting FaceBeauty's business team.

     ```
     [[FaceBeauty shareInstance] initFaceBeauty:@"<YOUR_APP_ID>" withDelegate:self];
     ```

8. Connect an Android or iOS physical device (not an emulator) and run the project.


#### Steps for Integrating the Flutter Plugin (Agora)

1. Agora RTC documentation: https://github.com/AgoraIO-Extensions/Agora-Flutter-SDK/blob/main/example/lib/examples/advanced/push_video_frame/push_video_frame.dart
2. Quick start:
   - Create an app ID, token, and channel on Agora by yourself, and let two devices join for debugging at the same time.
   - Agora's web demo can quickly show the room streaming,，https://webdemo.agora.io/basicVideoCall/index.html
3. Add Agora's APP ID, token, channel, and uID.
   - In `mtcamera-->lib-->app-->modules-->camera-->controllers-->camera_controller.dart` (can be located by searching for `todo fb`).
   - Agora RTC  streaming server

#### Key Process Description of Agora RTC Streaming Server

1. Flutter initializes Agora (`camera_controller.dart`)

   ```
   final _engine = createAgoraRtcEngine();
   await _engine.initialize(RtcEngineContext(appId: ...));
   await _engine.setClientRole(...);
   await _engine.setExternalVideoSource(enabled: true, useTexture: false);
   await _engine.enableVideo();
   await _engine.startPreview();
   ```

2. Flutter notifies the native layer to start capturing and streaming.

3. iOS native layer initializes the capturing logic (`IOSFlutterView.swift`)

   - ```
     func startPushToAgora() {
     
     faceBeauty.startCapture { imageBuffer in
     
     let bytes = bufferToBGRA(imageBuffer)
     
     sendToFlutter(bytes: bytes, width: ..., height: ..., stride: ...)
     
     }
     
     }
     ```

4. Flutter layer receives the native video frames and pushes them to Agora.

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

5. `mtcamera\lib\app\modules\camera\views\camera_view.dart` (Remote video in the top - right corner)
