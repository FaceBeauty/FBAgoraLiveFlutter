//
//  MTCaptureSessionManager.h
//  MTCamera
//
//  Created by iMacA1002 on 2020/4/23.
//  Copyright © 2020 Toivan Tech. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

 
//视频分辨率
 #define AV_CAPTURE_SESSION_PRESET_WIDTH 720
 #define AV_CAPTURE_SESSION_PRESET_HEIGHT 1280

@protocol MTCaptureSessionManagerDelegate <NSObject>

-(void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer Rotation:(NSInteger)rotation Mirror:(BOOL)isMirror;
 
@end

@interface MTCaptureSessionManager : NSObject
/**
*   初始化单例
*/
+ (MTCaptureSessionManager *)shareManager;
/**
 * 释放资源
 */
- (void)destroy;

-(void)startAVCaptureDelegate:(id<MTCaptureSessionManagerDelegate>)delegate;

- (void)didClickSwitchCameraButton;
 

@property(nonatomic, weak) id <MTCaptureSessionManagerDelegate> delegate;

@property (nonatomic, strong) AVCaptureDevice *cameraPosition;
@property (nonatomic, strong) AVCaptureSession *session;

@end
