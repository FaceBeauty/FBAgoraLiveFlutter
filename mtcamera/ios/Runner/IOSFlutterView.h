#import <UIKit/UIKit.h>
#import <AgoraRtcKit/AgoraRtcKit.h>
#import <Flutter/Flutter.h>

@interface IOSFlutterView : UIView
/**
*   初始化单例
*/
+ (IOSFlutterView *)shareManager;
@property (nonatomic, strong) FlutterMethodChannel *flutterChannel; // 添加属性

- (void)setAgoraEngine:(AgoraRtcEngineKit *)engine;

- (void)startPushToAgora;
- (void)stopPushToAgora;

- (void)initFaceBeautySDK;

@end
