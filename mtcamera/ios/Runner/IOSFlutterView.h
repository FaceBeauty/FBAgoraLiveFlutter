#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

@interface IOSFlutterView : UIView

- (void)initSDK;
/**
*   初始化单例
*/
+ (IOSFlutterView *_Nonnull)shareManager;
@property (nonatomic, strong) FlutterMethodChannel * _Nonnull flutterChannel; // 添加属性
- (void)startPushToAgora;
- (void)stopPushToAgora;
@end
