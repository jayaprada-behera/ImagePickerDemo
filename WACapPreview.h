//
//  WACaptureSession.h
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 04/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <AssetsLibrary/AssetsLibrary.h>

@interface WACapPreview : NSObject<AVCaptureFileOutputRecordingDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>{

}

@property (readwrite, copy) void (^videoRecordingCallBack)(NSURL *videoURL);
@property (readwrite, copy) void (^imageSnapCallBack)(UIImage *image);

-(void)initializeCaptureSessionOnPreview:(UIView *)view;

-(void)recordButton:(UIButton *)btn;
-(void)snapButton:(UIButton *)btn;
-(void)changeCameraButton:(UIButton *)btn;
@end
