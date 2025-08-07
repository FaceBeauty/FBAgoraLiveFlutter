
#import "IOSFlutterView.h"
#import "MTCaptureSessionManager.h"


#import <Masonry/Masonry.h>

#import <FaceBeauty/FaceBeauty.h>
#import <FaceBeauty/FaceBeautyView.h>
#import <FaceBeauty/FaceBeautyInterface.h>

#define window_width  [UIScreen mainScreen].bounds.size.width
#define window_height  [UIScreen mainScreen].bounds.size.height
static IOSFlutterView *shareManager = NULL;
static dispatch_once_t token;
@interface IOSFlutterView()<MTCaptureSessionManagerDelegate,FaceBeautyDelegate>

@property(nonatomic, strong) CIImage *outputImage;
@property(nonatomic, assign) CVPixelBufferRef outputImagePixelBuffer;

@property(nonatomic,assign)BOOL isRenderInit;
@property(nonatomic,assign)BOOL isCameraSwitched;

@property (nonatomic, strong) FaceBeautyView *fbLiveView;
@property (nonatomic, assign) BOOL shouldPushToAgora;

@end

@implementation IOSFlutterView
// MARK: --单例初始化方法--
+ (IOSFlutterView *)shareManager {
    dispatch_once(&token, ^{
        shareManager = [[IOSFlutterView alloc] init];
    });
    return shareManager;
}
- (void)startPushToAgora {
    NSLog(@"✅ Flutter调用了 startPushToAgora");
    self.shouldPushToAgora = YES;
}
-(void)stopPushToAgora
{
    NSLog(@"✅ Flutter调用了 stopPushToAgora");
    self.shouldPushToAgora = NO;
}


- (FaceBeautyView *)fbLiveView{
    if (!_fbLiveView) {
        _fbLiveView = [[FaceBeautyView alloc] init];
        _fbLiveView.contentMode = FaceBeautyViewContentModeScaleAspectFill;
        _fbLiveView.orientation = FaceBeautyViewOrientationLandscapeLeft;
        _fbLiveView.userInteractionEnabled = YES;
    }
    return _fbLiveView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
        [self initSDK];
    }
    return self;
}

- (void)initSDK{
    
    //todo ---facebeauty--- 初始化SDK
    BOOL isResourceCopied = NO;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FaceBeauty" ofType:@"bundle"];
    
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if (libraryPaths.count > 0) {
        NSString *libraryDirectory = [libraryPaths lastObject];
        NSString *sandboxPath = [libraryDirectory stringByAppendingPathComponent:@"FaceBeauty"];
        isResourceCopied = [[FaceBeauty shareInstance] copyResourceBundle:bundlePath toSandbox:sandboxPath];
    }
    
    NSString *version = [[FaceBeauty shareInstance] getVersion];
    NSLog(@"当前FaceBeauty版本 %@", version ?: @"");
    
    // todo fb 需要FaceBeauty appid，与包名应用名绑定，请联系商务获取
    if (isResourceCopied) {
        [[FaceBeauty shareInstance] initFaceBeauty:@"YOUR_APP_ID" withDelegate:self];
    }
    
    [[MTCaptureSessionManager shareManager] startAVCaptureDelegate:self];
    
    self.userInteractionEnabled = YES;
    
    
}

- (void)setUI{
    
    [self addSubview:self.fbLiveView];
    CGFloat imageOnPreviewScale = MAX(window_width / AV_CAPTURE_SESSION_PRESET_WIDTH, window_height / AV_CAPTURE_SESSION_PRESET_HEIGHT);
    CGFloat previewImageWidth = AV_CAPTURE_SESSION_PRESET_WIDTH * imageOnPreviewScale;
    CGFloat previewImageHeight = AV_CAPTURE_SESSION_PRESET_HEIGHT * imageOnPreviewScale;
    
    [self.fbLiveView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(previewImageWidth);
        make.height.mas_equalTo(previewImageHeight);
    }];
}

// MARK: --FaceBeautyDelegate Delegate--

- (void)onInitSuccess{
    NSLog(@"FaceBeauty 加载成功");
    [self initBeautyData];
}

- (void)onInitFailure{
    NSLog(@"FaceBeauty 加载失败");
}

- (void)initBeautyData{
    //开启美颜渲染
    [[FaceBeauty shareInstance] setRenderEnable:true];
    
    [[FaceBeauty shareInstance] setBeauty:FBBeautySkinWhitening value:70];
    [[FaceBeauty shareInstance] setBeauty:FBBeautyClearSmoothing value:80];
    [[FaceBeauty shareInstance] setBeauty:FBBeautySkinRosiness value:10];
    [[FaceBeauty shareInstance] setBeauty:FBBeautyImageSharpness value:5];
    [[FaceBeauty shareInstance] setBeauty:FBBeautyImageBrightness value:0];
    
    [[FaceBeauty shareInstance] setReshape:FBReshapeEyeEnlarging value:60];
    [[FaceBeauty shareInstance] setReshape:FBReshapeCheekThinning value:30];
    [[FaceBeauty shareInstance] setReshape:FBReshapeCheekVShaping value:50];
    
    [[FaceBeauty shareInstance] setFilter:FBFilterBeauty name:@"ziran3"];
}

/**
 * 切换摄像头
 */
- (void)didClickSwitchCameraButton:(UIButton *)sender{
    
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    [[MTCaptureSessionManager shareManager] didClickSwitchCameraButton];
    _isCameraSwitched = true;
    
}

// MARK: --MTCaptureSessionManager Delegate--

-(void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer Rotation:(NSInteger)rotation Mirror:(BOOL)isMirror{
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == NULL) {
        return;
    }
    
    // Objective-C 限制帧率为 15fps
    static CFAbsoluteTime lastPushTime = 0;
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    if (now - lastPushTime < 1.0 / 15.0) return;
    lastPushTime = now;
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char *baseAddress = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    // 视频帧格式
    FBFormatEnum format;
    switch (CVPixelBufferGetPixelFormatType(pixelBuffer)) {
        case kCVPixelFormatType_32BGRA:
            format = FBFormatBGRA;
            break;
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            format = FBFormatNV12;
            break;
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
            format = FBFormatNV12;
            break;
        default:
            NSLog(@"错误的视频帧格式！");
            format = FBFormatBGRA;
            break;
    }
    int imageWidth, imageHeight;
    if (format == FBFormatBGRA) {
        imageWidth = (int)CVPixelBufferGetBytesPerRow(pixelBuffer) / 4;
        imageHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    } else {
        imageWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer , 0);
        imageHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer , 0);
    }
    if (_isCameraSwitched) {
        [[FaceBeauty shareInstance] releaseBufferRenderer];
        _isCameraSwitched = false;
        _isRenderInit = false;
    }
    //todo ---facebeauty---
    //添加渲染
    if (!_isRenderInit) {
        _isRenderInit = [[FaceBeauty shareInstance] initBufferRenderer:FBFormatBGRA width:imageWidth height:imageHeight rotation:FBRotationClockwise90 isMirror:isMirror maxFaces:5];
    }
    
    [[FaceBeauty shareInstance] processBuffer:baseAddress];
    
    [self.fbLiveView displayPixelBuffer:pixelBuffer isMirror:isMirror];
    
    self.outputImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    self.outputImagePixelBuffer = pixelBuffer;
    if (self.shouldPushToAgora) {
        [self sendFrameToFlutter:pixelBuffer];
    }else{
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
}
#pragma mark - 推送帧到 Agora
- (void)sendFrameToFlutter:(CVPixelBufferRef)pixelBuffer {
    
    if (!self.flutterChannel) {
        NSLog(@"❌ Flutter 通道未设置");
        return;
    }
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // 创建 NSData 传输（注意：这里是 BGRA 格式）
    NSData *frameData = [NSData dataWithBytes:baseAddress length:height * bytesPerRow];
    FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:frameData];
    //    NSLog(@"NSData 传输=======%@",frameData);
    NSDictionary *args = @{
        @"width": @(width),
        @"height": @(height),
        @"stride": @(bytesPerRow),
        @"format": @(11), // AgoraVideoPixelFormatBGRA
        @"bytes": typedData
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.flutterChannel invokeMethod:@"onFrame" arguments:args];
    });
}



- (void)dealloc {
    [[FaceBeauty shareInstance] releaseBufferRenderer];
}


@end
