//
//  MTCaptureSessionManager.m
//  MTCamera
//
//  Created by iMacA1002 on 2020/4/23.
//  Copyright © 2020 Toivan Tech. All rights reserved.
//

#import "MTCaptureSessionManager.h"

static MTCaptureSessionManager *shareManager = NULL;
static dispatch_once_t token;

@interface MTCaptureSessionManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@end
 
@implementation MTCaptureSessionManager

// MARK: --单例初始化方法--
+ (MTCaptureSessionManager *)shareManager {
    dispatch_once(&token, ^{
        shareManager = [[MTCaptureSessionManager alloc] init];
    });
    return shareManager;
}

+ (void)releaseShareManager{
    token = 0;
    //只有置成0,GCD才会认为它从未执行过.它默认为0.这样才能保证下次再次调用shareInstance的时候,再次创建对象.
//   [shareManager release];
   shareManager = nil;
}

- (instancetype)init{
    if ([super init]) {}
    return self;
}

- (void)startAVCaptureDelegate:(id<MTCaptureSessionManagerDelegate>)delegate{
    self.delegate = delegate;
    self.session = [[AVCaptureSession alloc] init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.cameraPosition = [self cameraWithPosition:AVCaptureDevicePositionFront];
        // 判断视频帧尺寸
        if ([self.cameraPosition supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
            NSLog(@"当前分辨率1920x1080");
            [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }else{
            [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
            NSLog(@"当前分辨率1280x720");
        }
    }
    else
    {
        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    // 设置摄像头采集位置（前置/后置）
    // 默认为前置摄像头
    if (@available(iOS 10.0, *)) {
        NSArray *devices = [[AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront] devices];
        for (AVCaptureDevice *device in devices) {
            if ([device hasMediaType: AVMediaTypeVideo]) {
                if ([device position] == AVCaptureDevicePositionFront) {
                    self.cameraPosition = device;
                }
            }
        }
    } else {
        // Fallback on earlier versions
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice: self.cameraPosition error:&error];
    if (!input) {
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames: true];
    [dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}]; // 设置视频帧格式
    dispatch_queue_t queue = dispatch_queue_create("dataOutputQueue", NULL);
    [dataOutput setSampleBufferDelegate:self queue:queue];
      
    
    [self.session beginConfiguration];
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:dataOutput]) {
        [self.session addOutput:dataOutput];
    }
    
    // 视频帧采集的方向
//    AVCaptureConnection *connection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
//    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [self.session commitConfiguration];
    [self.session startRunning];
    
}

// 视频帧回调函数
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  
    BOOL isMirror = ([self.cameraPosition position] == AVCaptureDevicePositionFront);
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    NSInteger rotation;
    switch (orientation) {
       case UIDeviceOrientationPortrait:
           rotation = 90;
           break;
       case UIDeviceOrientationLandscapeLeft:
           rotation = isMirror ? 180 : 0;
           break;
       case UIDeviceOrientationLandscapeRight:
           rotation = isMirror ? 0 : 180;
           break;
       case UIDeviceOrientationPortraitUpsideDown:
           rotation = 270;
           break;
       default:
           rotation = 90;
           break;
   }
    if (self.delegate) {
        [self.delegate captureSampleBuffer:sampleBuffer Rotation:rotation Mirror:isMirror];
    }
    
}

- (void)didClickSwitchCameraButton {
    
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        //先移除当前摄像头采集的画面
        [self.session removeInput:input];
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            self.cameraPosition = nil;
            AVCaptureDeviceInput *newInput = nil;
            if (position == AVCaptureDevicePositionFront){
                self.cameraPosition = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }else{
                self.cameraPosition = [self cameraWithPosition:AVCaptureDevicePositionFront];
            }
            // 判断视频帧尺寸
            if ([self.cameraPosition supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
                NSLog(@"当前分辨率1920x1080");
                [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
            }else{
                [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
                NSLog(@"当前分辨率1280x720");
            }
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraPosition error:nil];
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.session beginConfiguration];
            [self.session addInput:newInput];
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            break;
        }
    }
    
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

// MARK: --destroy释放 相关代码--
- (void)destroy{
    [self.session stopRunning];
    [MTCaptureSessionManager releaseShareManager];
}

@end
