//
//  WACaptureSession.m
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 04/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WACapPreview.h"

#define CAPTURE_FRAMES_PER_SECOND		20

@interface WACapPreview (){
    
    AVCaptureDeviceInput *input;
    AVCaptureMovieFileOutput *output;
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
}
@end

@implementation WACapPreview
@synthesize videoRecordingCallBack;
@synthesize imageSnapCallBack;

-(void)initializeCaptureSessionOnPreview:(UIView *)view{
    
    //create a session
    session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];
    session.sessionPreset = AVCaptureSessionPresetHigh;//AVCaptureSessionPresetHigh is default sessionPreset value.
    
    CALayer *viewLayer = view.layer;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.frame = view.bounds;
    
    [viewLayer addSublayer:captureVideoPreviewLayer];

    captureVideoPreviewLayer.connection.videoOrientation = UIDevice.currentDevice.orientation;

    //all the available devices and logs their name
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *cameraDevice;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                cameraDevice = device;
            }
            else {
                NSLog(@"Device position : front");
                cameraDevice = device;
            }
        }
    }
    //    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Add video inputs
    NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    if (!input) {
        // Handle the error appropriately.
    }else{
        //check whether a capture input is compatible with an existing session
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
    }
        // Add audio inputs
    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    if (error)
    {
        NSLog(@"%@", error);
    }
    
    if ([session canAddInput:audioDeviceInput])
    {
        [session addInput:audioDeviceInput];
    }
    
    //Capturing still images
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([session canAddOutput:stillImageOutput])
    {
        [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
        [session addOutput:stillImageOutput];
    }

    // Add  outputs.
    output = [[AVCaptureMovieFileOutput alloc]init];

    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    
    
    [session commitConfiguration];
    
    //----- START THE CAPTURE SESSION RUNNING -----

    [session startRunning];
    
//    [output startRecordingToOutputFileURL:outputURL recordingDelegate:self];

    
    //    //Configure outful and start session
    //    dispatch_queue_t queue = dispatch_queue_create("myqueue", NULL);
    //    [output setSampleBufferDelegate:self queue:queue];
    //    [session startRunning];
    
    //    [self setSession:session]; // crashes
    
    //    if (![session isRunning])
    //    {
    //        [self performSelector:@selector(startRecording) withObject:nil afterDelay:1.0];
    //        [session startRunning];
    //    }
    
    /*
     [session beginConfiguration];
     // Remove an existing capture device.
     // Add a new capture device.
     // Reset the preset.
     [session commitConfiguration];
     
     */
    
}

- (void) CameraSetOutputPropertiesFor:(AVCaptureMovieFileOutput *)movieFileOutput
{
	//SET THE CONNECTION PROPERTIES (output properties)
	AVCaptureConnection *CaptureConnection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
	
	//Set landscape (if required)
	if ([CaptureConnection isVideoOrientationSupported])
	{
		AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;		//<<<<<SET VIDEO ORIENTATION IF LANDSCAPE
		[CaptureConnection setVideoOrientation:orientation];
	}
	
	//Set frame rate (if requried)
	CMTimeShow(CaptureConnection.videoMinFrameDuration);
	CMTimeShow(CaptureConnection.videoMaxFrameDuration);
	
	if (CaptureConnection.supportsVideoMinFrameDuration)
		CaptureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
	if (CaptureConnection.supportsVideoMaxFrameDuration)
		CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
	
	CMTimeShow(CaptureConnection.videoMinFrameDuration);
	CMTimeShow(CaptureConnection.videoMaxFrameDuration);
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
   
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
	{
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
		{
            RecordedSuccessfully = [value boolValue];
        }
    }
	if (RecordedSuccessfully)
	{
		//----- RECORDED SUCESSFULLY -----
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        
        self.videoRecordingCallBack(outputFileURL);
//		ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//		if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
//		{
//			[library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
//										completionBlock:^(NSURL *assetURL, NSError *error)
//             {
//                 if (error)
//                 {
//                     
//                 }
//             }];
//		}
	}
}
-(void)recordButton:(UIButton *)btn{

    //TODO:Record Multiple Videos
    if (![output isRecording]){
        [btn setTitle:@"STOP" forState:UIControlStateNormal];
        NSLog(@"start Recording");
//        NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"me.mov"];

        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:filePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath]) {
            NSLog(@"file saved");
        }
        [output startRecordingToOutputFileURL:outputURL recordingDelegate:self];

    }else{
        NSLog(@"stop Recording");

        [btn setTitle:@"Record" forState:UIControlStateNormal];
        [output stopRecording];

//        [session beginConfiguration];
        // Remove an existing capture device.
        // Add a new capture device.
        // Reset the preset.
//        [session commitConfiguration];
    }
}
-(void)snapButton:(UIButton *)btn{
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer)
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            self.imageSnapCallBack(image);
//            [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
        }
    }];
}
-(void)changeCameraButton:(UIButton *)btn{
    AVCaptureDevice *currentVideoDevice = [input device];
    AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
    AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
    
    switch (currentPosition)
    {
        case AVCaptureDevicePositionUnspecified:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
        case AVCaptureDevicePositionBack:
            preferredPosition = AVCaptureDevicePositionFront;
            break;
        case AVCaptureDevicePositionFront:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
    }
    
    AVCaptureDevice *videoDevice = [WACapPreview deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    
    [session beginConfiguration];
    
    [session removeInput:input];
    if ([session canAddInput:videoDeviceInput])
    {
        
        [session addInput:videoDeviceInput];
        input = videoDeviceInput;
    }
    else
    {
        [session addInput:input];
    }
    
    [session commitConfiguration];

}
+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position{
    
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices){
        
		if ([device position] == position){
            
			captureDevice = device;
			break;
		}
	}
	return captureDevice;
}

//http://stackoverflow.com/questions/8191840/video-encoding-using-avassetwriter-crashes

//http://stackoverflow.com/questions/3741323/how-do-i-export-uiimage-array-as-a-movie/3742212#3742212

//generating single image for uicollectionviewcell
//https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html
//http://abdulazeem.wordpress.com/2012/04/02/video-manipulation-in-ios-resizingmerging-and-overlapping-videos-in-ios/
@end
