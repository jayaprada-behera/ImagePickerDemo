//
//  WAVideoPlayViewController.m
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 03/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WAVideoPlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#define FB_APP_ID   @"264764970366965"//mention in info.plist


@interface WAVideoPlayViewController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet UIActivityIndicatorView *spinner;
    MPMoviePlayerController *movieController;
    int height,width;
    NSURL *fullPath;
    NSString *presetName;
    
    __weak IBOutlet UIButton *cancelResizeButton;
}
- (IBAction)cancelResizeButtonTouchUpInside:(id)sender;
- (IBAction)fbShareButtonTouchUpInside:(id)sender;
@end

@implementation WAVideoPlayViewController
@synthesize videoURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//How to use audio file and its customisation like adding volume slider

- (void)viewDidLoad
{
    [super viewDidLoad];
    spinner.hidden = YES;
    if(self.videoURL == nil){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* foofile = [documentsDirectory stringByAppendingPathComponent:@"me.mov"];
        BOOL fileExists = [fileManager fileExistsAtPath:foofile];

        if (fileExists) {
            
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"myVideo" ofType:@"type"];//foofile;
        NSURL *pathURL = [[NSURL alloc]initFileURLWithPath:filePath isDirectory:NO];
        self.videoURL = pathURL;
    }
    movieController = [[MPMoviePlayerController alloc] initWithContentURL:self.videoURL];
    [movieController prepareToPlay];
    [movieController.view setFrame:playView.frame];
    
    movieController.controlStyle = MPMovieControlStyleDefault;
    movieController.shouldAutoplay = YES;
    [movieController setFullscreen:NO animated:YES];
    movieController.movieSourceType = MPMovieSourceTypeFile;
    
    //    movieController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    //    UIViewAutoresizingFlexibleRightMargin |
    //    UIViewAutoresizingFlexibleTopMargin |
    //    UIViewAutoresizingFlexibleBottomMargin |
    //    UIViewAutoresizingFlexibleHeight |
    //    UIViewAutoresizingFlexibleWidth;
    
    [playView addSubview:movieController.view];
    if (movieController.readyForDisplay) {
        NSLog(@"ready to display");
    }
    resizeOverlayView.backgroundColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:0.5f];
    //    [self pl:videoURL];
}
-(void)pl:(NSURL *)url{
    MPMoviePlayerController *p =[[MPMoviePlayerController alloc]initWithContentURL:url];
    p = movieController;
    [p play];
    
}

- (void)uploadWithFBAccount:(ACAccount *)facebookAccount{
    ACAccountCredential *fbCredential = [facebookAccount credential];
    NSString *accessToken = [fbCredential oauthToken];
    
    NSURL *videourl = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/videos?access_token=%@",accessToken]];
    
    
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",accessToken]];
    NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:@"picture,id,name,installed",@"fields", nil];
    
    SLRequest *getFriendslist = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:@{@"fields":@"id,name,picture,first_name,last_name,gender"}];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        [getFriendslist performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSLog(@"%@",error.description);
            NSLog(@"%ld",(long)urlResponse.statusCode);
            if (error.code == -1009) {
                NSLog(@"%@",error.description);
            }
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            if (urlResponse.statusCode == 200) {
                [[[UIAlertView alloc]initWithTitle:@"Congratulations!" message:@"Your video is suucessfully posted to your FB newsfeed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            }
            if(error){
                NSLog(@"Error %@", error.localizedDescription);
            }else
            {
                NSLog(@"%@", responseString);
            }
        }];
    });
    
    /*
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* foofile = [documentsDirectory stringByAppendingPathComponent:@"me.mov"];
    BOOL fileExists = [fileManager fileExistsAtPath:foofile];
    if (fileExists) {
        NSLog(@"fileExists");}
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"myVideo" ofType:@"type"];//foofile;
    NSURL *pathURL = [[NSURL alloc]initFileURLWithPath:filePath isDirectory:NO];
    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *params = @{
                             @"title": @"Me  silly",
                             @"description": @"Me testing the video upload to Facebook with the new Social Framework."
                             };
   
    SLRequest *uploadRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                  requestMethod:SLRequestMethodPOST
                                                            URL:videourl
                                                     parameters:params];
    [uploadRequest addMultipartData:videoData
                           withName:@"source"
                               type:@"video/quicktime"
                           filename:[pathURL absoluteString]];
    
    uploadRequest.account = facebookAccount;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        [uploadRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSLog(@"%@",error.description);
            NSLog(@"%ld",(long)urlResponse.statusCode);
            if (error.code == -1009) {
                NSLog(@"%@",error.description);
            }
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            if (urlResponse.statusCode == 200) {
                [[[UIAlertView alloc]initWithTitle:@"Congratulations!" message:@"Your video is suucessfully posted to your FB newsfeed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            }
            if(error){
                NSLog(@"Error %@", error.localizedDescription);
            }else
            {
                NSLog(@"%@", responseString);
            }
        }];
    });
    */
}
-(void)shareOnFB{
    
    __block ACAccount * facebookAccount;
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    NSDictionary *emailReadPermisson = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        FB_APP_ID,ACFacebookAppIdKey,
                                        @[@"email"],ACFacebookPermissionsKey,
                                        ACFacebookAudienceFriends,ACFacebookAudienceKey,
                                        nil];
    
    NSDictionary *publishWritePermisson = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           FB_APP_ID,ACFacebookAppIdKey,
                                           @[@"publish_stream"],ACFacebookPermissionsKey,
                                           ACFacebookAudienceFriends,ACFacebookAudienceKey,
                                           nil];
    
    ACAccountType *facebookAccountType = [accountStore
                                          accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    //Request for Read permission
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:emailReadPermisson completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            
            //Request for write permission
            [accountStore requestAccessToAccountsWithType:facebookAccountType options:publishWritePermisson completion:^(BOOL granted, NSError *error) {
            
                if (granted) {
                    NSArray *accounts = [accountStore
                                         accountsWithAccountType:facebookAccountType];
                    facebookAccount = [accounts lastObject];
                    NSLog(@"access to facebook account ok %@", facebookAccount.username);
                    [self uploadWithFBAccount:facebookAccount];
                    
                } else {
                    
                    NSLog(@"access to facebook is not granted");
                    // extra handling here if necesary
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Fail gracefully...
                        NSLog(@"%@",error.description);
                        [self errorMethodFromFB:error];
                        
                    });
                }
            }];
        }else{
            [self errorMethodFromFB:error];
        }
    }];
}

-(void)errorMethodFromFB:(NSError *)error{
   
    NSLog(@"access to facebook is not granted");
    // extra handling here if necesary
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Fail gracefully...
        NSLog(@"%@",error.description);
        
        if([error code]== ACErrorAccountNotFound)
            [self throwAlertWithTitle:@"Error" message:@"Account not found. Please setup your account in settings app."];
        if ([error code] == ACErrorAccessInfoInvalid)
            [self throwAlertWithTitle:@"Error" message:@"The client's access info dictionary has incorrect or missing values."];
        if ([error code] ==  ACErrorPermissionDenied)
            [self throwAlertWithTitle:@"Error" message:@"The operation didn't complete because the user denied permission."];
        else
            [self throwAlertWithTitle:@"Error" message:@"Account access denied."];
    });
}
-(void)throwAlertWithTitle:(NSString *)title message:(NSString *)msg{
    
    [[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
}


#pragma mark -  UIButton Actions

- (IBAction)cancelResizeButtonTouchUpInside:(id)sender {
    
    resizeOverlayView.hidden = YES;
    
}
- (IBAction)fbShareButtonTouchUpInside:(id)sender {
    [self shareOnFB];
}
- (IBAction)lessQualityButtonTouchUpInside:(id)sender {
    
    presetName = AVAssetExportPreset640x480;
    
    //    height = 480;
    //    width = 640;
    
}

- (IBAction)goodQualityButtonTouchUpInside:(id)sender {
    
    presetName = AVAssetExportPreset960x540;
    
    //    height = 540;
    //    width = 960;
    
}

- (IBAction)hdVideoButtonTouchUpInside:(id)sender {
    
    presetName = AVAssetExportPreset1920x1080;
    //    height = 1080;
    //    width = 1920;
    
}

- (IBAction)highQualityButtonTouchUpInside:(id)sender {
    
    presetName = AVAssetExportPreset1280x720;
    //    height = 720;
    //    width = 1280;
    
}

- (IBAction)resizeDoneButtonTouchUpInside:(id)sender {
    
    if (presetName.length == 0) {
        return;
    }
    resizeOverlayView.hidden = YES;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.videoURL options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    CGSize mediaSize = track.naturalSize;
    NSLog(@"media size,h:%f,w:%f",mediaSize.height,mediaSize.width);
    [self trimVideoWithURL:self.videoURL];
}

- (IBAction)playVideoButtonTouchUpInside:(id)sender {
    if (fullPath == nil) {
        return;
    }
    MPMoviePlayerController *p =[[MPMoviePlayerController alloc]initWithContentURL:fullPath];
    p = movieController;
    [p play];
    
}

- (IBAction)resizeButtonTouchUpInside:(id)sender {
    
    [movieController stop];
    resizeOverlayView.hidden = NO;
}

-(IBAction)doneButtonTouchUpInside:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

/*
 AVAssetExportPreset640x480
 AVAssetExportPreset960x540
 AVAssetExportPreset1280x720
 AVAssetExportPreset1920x1080
 
 high (1280х720) = ~14MB = ~11Mbit/s
 640 (640х480) = ~4MB = ~3.2Mbit/s
 medium (360х480) = ~1MB = ~820Kbit/s
 low (144х192) = ~208KB = ~170Kbit/s
 
 */

-(void)trimVideoWithURL:(NSURL *)inputURL{
    
    NSString *path1 = [inputURL path];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path1];
    NSLog(@"size before compress video is %lu",(unsigned long)data.length);
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:presetName];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mov"];
    fullPath = [NSURL URLWithString:outputURL];
    
    // Remove Existing File
//    
//    [manager removeItemAtPath:outputURL error:nil];
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    CMTime start = CMTimeMakeWithSeconds(1.0, 600);
    CMTime duration = CMTimeMakeWithSeconds(1.0, 600);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
                 
             case AVAssetExportSessionStatusCompleted:{
                 
                 NSString *path = [fullPath path];
                 NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
                 NSLog(@"size after compress video is %lu",(unsigned long)data.length);
                 NSLog(@"Export Complete %ld %@", (long)exportSession.status, exportSession.error);
                 /*
                  Do your neccessay stuff here after compression
                  */
             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@",exportSession.error);
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@",exportSession.error);
                 break;
             default:
                 break;
         }
     }];
}
-(void)compressMyVideoWithURL:(NSURL *)url{
    
    NSString  *pathy = [[[url absoluteString] componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *newName = [pathy stringByAppendingString:@"down.mov"];
    fullPath = [NSURL URLWithString:newName];
    
    NSURL *path = url;
    
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:fullPath fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary* compressionSettings = @{ AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31,
                                           AVVideoAverageBitRateKey: [NSNumber numberWithInt:2500000],
                                           AVVideoMaxKeyFrameIntervalKey: [NSNumber numberWithInt: 30] };
    
    NSDictionary* videoSettings = @{ AVVideoCodecKey: AVVideoCodecH264,
                                     AVVideoWidthKey: [NSNumber numberWithInt:width],
                                     AVVideoHeightKey: [NSNumber numberWithInt:height],
                                     AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
                                     AVVideoCompressionPropertiesKey: compressionSettings };
    
    //    NSDictionary* settings1 = [NSDictionary dictionaryWithObjectsAndKeys:
    //                              AVVideoCodecH264, AVVideoCodecKey,
    //
    //                              [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2500000],AVVideoAverageBitRateKey ,
    //                               AVVideoProfileLevelH264Main31, AVVideoProfileLevelKey,
    //                               [NSNumber numberWithInt: 30], AVVideoMaxKeyFrameIntervalKey,nil],
    //
    //                              AVVideoCompressionPropertiesKey,
    //                              [NSNumber numberWithInt:width], AVVideoWidthKey,
    //                              [NSNumber numberWithInt:height], AVVideoHeightKey, nil];
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    
    videoWriterInput.expectsMediaDataInRealTime = NO;
    
    [videoWriter addInput:videoWriterInput];
    
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:path options:nil];
    NSError *aerror = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&aerror];
    
    AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
    
    NSDictionary *videoOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    AVAssetReaderTrackOutput *asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
    
    [reader addOutput:asset_reader_output];
    
    
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:nil] ;
    
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:&error];
    NSArray *audio =[avAsset tracksWithMediaType:AVMediaTypeAudio];
    
    AVAssetTrack* audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    AVAssetReaderOutput *readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    
    [audioReader addOutput:readerOutput];
    
    NSParameterAssert(audioWriterInput);
    NSParameterAssert([videoWriter canAddInput:audioWriterInput]);
    audioWriterInput.expectsMediaDataInRealTime = NO;
    
    [videoWriter addInput:audioWriterInput];
    
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    [reader startReading];
    
    NSString *path1 = [url path];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path1];
    NSLog(@"size before compress video is %lu",(unsigned long)data.length);
    
    dispatch_queue_t _processingQueue = dispatch_queue_create("assetAudioWriterQueue", NULL);
    
    [videoWriterInput requestMediaDataWhenReadyOnQueue:_processingQueue usingBlock:
     ^{
         [self.view bringSubviewToFront:spinner];
         
         spinner.hidden = NO;
         [spinner startAnimating];
         while ([videoWriterInput isReadyForMoreMediaData]) {
             
             CMSampleBufferRef sampleBuffer;
             
             if ([reader status] == AVAssetReaderStatusReading) {
                 
                 if(![videoWriterInput isReadyForMoreMediaData])
                     continue;
                 
                 sampleBuffer = [asset_reader_output copyNextSampleBuffer];
                 
                 NSLog(@"READING");
                 
                 if(sampleBuffer)
                     [videoWriterInput appendSampleBuffer:sampleBuffer];
                 
                 NSLog(@"WRITTING...");
                 
                 
             } else {
                 [videoWriterInput markAsFinished];
                 
                 switch ([reader status]) {
                     case AVAssetReaderStatusReading:
                         // the reader has more for other tracks, even if this one is done
                         break;
                         
                     case AVAssetReaderStatusCompleted:
                         spinner.hidden = YES;
                         // your method for when the conversion is done
                         // should call finishWriting on the writer
                         //hook up audio track
                     {
                         NSString *path = [fullPath path];
                         NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
                         
                         NSLog(@"size after compress video is %lu",(unsigned long)data.length);
                         
                         [videoWriter startSessionAtSourceTime:kCMTimeZero];
                         
                         dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
                         /*
                          [audioWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^
                          {
                          NSLog(@"Request");
                          NSLog(@"Asset Writer ready :%d",audioWriterInput.readyForMoreMediaData);
                          
                          while (audioWriterInput.readyForMoreMediaData) {
                          CMSampleBufferRef nextBuffer;
                          
                          if ([audioReader status] == AVAssetReaderStatusReading &&
                          (nextBuffer = [readerOutput copyNextSampleBuffer])) {
                          
                          NSLog(@"Ready");
                          if (nextBuffer) {
                          NSLog(@"NextBuffer");
                          [audioWriterInput appendSampleBuffer:nextBuffer];
                          }
                          
                          }else{
                          [audioWriterInput markAsFinished];
                          switch ([audioReader status]) {
                          case AVAssetReaderStatusCompleted:
                          //                                                [videoWriter finishWriting];
                          //                                                [self hookUpVideo:newName];
                          break;
                          }
                          }
                          }
                          
                          }
                          ];
                          */
                         break;
                     }
                     case AVAssetReaderStatusFailed:
                     {
                         spinner.hidden = YES;
                         [videoWriter cancelWriting];
                         break;
                     }
                 }
                 break;
             }
         }
     }
     ];
}
/*
 -(void)compressFile:(NSURL*)inUrl;
 {
 //    NSString* fileName = [@"compressed." stringByAppendingString:inUrl.lastPathComponent];
 NSError* error;
 
 NSString  *pathy = [[[inUrl absoluteString] componentsSeparatedByString:@"."] objectAtIndex:0];
 NSString *newName = [pathy stringByAppendingString:@"down.mov"];
 NSURL *outUrl = [NSURL fileURLWithPath:newName];
 
 //    NSURL* outUrl = [PlatformHelper getFilePath:fileName error:&error];
 
 NSDictionary* compressionSettings = @{ AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31,
 AVVideoAverageBitRateKey: [NSNumber numberWithInt:2500000],
 AVVideoMaxKeyFrameIntervalKey: [NSNumber numberWithInt: 30] };
 
 NSDictionary* videoSettings = @{ AVVideoCodecKey: AVVideoCodecH264,
 AVVideoWidthKey: [NSNumber numberWithInt:width],
 AVVideoHeightKey: [NSNumber numberWithInt:height],
 AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
 AVVideoCompressionPropertiesKey: compressionSettings };
 
 NSDictionary* videoOptions = @{ (id)kCVPixelBufferPixelFormatTypeKey:
 [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] };
 
 
 AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
 writerInput.expectsMediaDataInRealTime = YES;
 
 AVAssetWriter* assetWriter = [AVAssetWriter assetWriterWithURL:outUrl fileType:AVFileTypeMPEG4 error:&error];
 assetWriter.shouldOptimizeForNetworkUse = YES;
 
 [assetWriter addInput:writerInput];
 
 AVURLAsset* asset = [AVURLAsset URLAssetWithURL:inUrl options:nil];
 AVAssetTrack* videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
 
 // !!! this line does not work as expected and causes all sorts of issues (videos display sideways in some cases) !!!
 //writerInput.transform = videoTrack.preferredTransform;
 
 AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:videoOptions];
 AVAssetReader* assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
 
 [assetReader addOutput:readerOutput];
 
 [assetWriter startWriting];
 [assetWriter startSessionAtSourceTime:kCMTimeZero];
 [assetReader startReading];
 
 dispatch_queue_t _processingQueue = dispatch_queue_create("assetAudioWriterQueue", NULL);
 
 [writerInput requestMediaDataWhenReadyOnQueue:_processingQueue usingBlock:
 ^{
 while ([writerInput isReadyForMoreMediaData]) {
 
 CMSampleBufferRef sampleBuffer;
 
 if ([assetReader status] == AVAssetReaderStatusReading &&
 (sampleBuffer = [readerOutput copyNextSampleBuffer])) {
 
 BOOL result = [writerInput appendSampleBuffer:sampleBuffer];
 
 CFRelease(sampleBuffer);
 
 if (!result) {
 [assetReader cancelReading];
 break;
 }
 
 } else {
 [writerInput markAsFinished];
 
 switch ([assetReader status]) {
 case AVAssetReaderStatusReading:
 // the reader has more for other tracks, even if this one is done
 break;
 
 case AVAssetReaderStatusCompleted:
 // your method for when the conversion is done
 // should call finishWriting on the writer
 //hook up audio track
 {
 [assetWriter startSessionAtSourceTime:kCMTimeZero];
 
 break;
 }
 case AVAssetReaderStatusFailed:
 {
 [assetWriter cancelWriting];
 break;
 }
 }
 break;
 }
 }
 }];
 }
 -(void)resizeVideo:(NSURL *)urlPath{
 
 NSString  *pathy = [[[urlPath absoluteString] componentsSeparatedByString:@"."] objectAtIndex:0];
 NSString *newName = [pathy stringByAppendingString:@"down.mov"];
 NSURL *fullPath = [NSURL fileURLWithPath:newName];
 
 NSURL *path = [NSURL fileURLWithPath:pathy];
 
 NSLog(@"Write Started");
 
 NSError *error = nil;
 
 AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:fullPath fileType:AVFileTypeQuickTimeMovie error:&error];
 NSParameterAssert(videoWriter);
 AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:urlPath options:nil];
 NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
 AVVideoCodecH264, AVVideoCodecKey,
 [NSNumber numberWithInt:width], AVVideoWidthKey,
 [NSNumber numberWithInt:height], AVVideoHeightKey,
 nil];
 
 AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
 assetWriterInputWithMediaType:AVMediaTypeVideo
 outputSettings:videoSettings];
 NSParameterAssert(videoWriterInput);
 NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
 videoWriterInput.expectsMediaDataInRealTime = YES;
 [videoWriter addInput:videoWriterInput];
 
 NSError *aerror = nil;
 
 AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&aerror];
 //Check if avAsset has any object
 AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
 videoWriterInput.transform = videoTrack.preferredTransform;
 
 NSDictionary *videoOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
 
 AVAssetReaderTrackOutput *asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
 [reader addOutput:asset_reader_output];
 //audio setup
 
 //    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
 //                                            assetWriterInputWithMediaType:AVMediaTypeAudio
 //                                            outputSettings:nil] ;
 
 AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:&error];
 NSArray *audio =[avAsset tracksWithMediaType:AVMediaTypeAudio];
 NSArray *video =[avAsset tracksWithMediaType:AVMediaTypeVideo];
 
 //    AVAssetTrack* audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
 
 //    AVAssetReaderOutput *readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
 
 //    [audioReader addOutput:readerOutput];
 
 //    NSParameterAssert(audioWriterInput);
 //    NSParameterAssert([videoWriter canAddInput:audioWriterInput]);
 //    audioWriterInput.expectsMediaDataInRealTime = NO;
 
 //    [videoWriter addInput:audioWriterInput];
 [videoWriter startWriting];
 [videoWriter startSessionAtSourceTime:kCMTimeZero];
 [reader startReading];
 
 dispatch_queue_t _processingQueue = dispatch_queue_create("assetAudioWriterQueue", NULL);
 [videoWriterInput requestMediaDataWhenReadyOnQueue:_processingQueue usingBlock:
 ^{
 while ([videoWriterInput isReadyForMoreMediaData]) {
 
 CMSampleBufferRef sampleBuffer;
 
 if ([reader status] == AVAssetReaderStatusReading &&
 (sampleBuffer = [asset_reader_output copyNextSampleBuffer])) {
 
 BOOL result = [videoWriterInput appendSampleBuffer:sampleBuffer];
 
 CFRelease(sampleBuffer);
 
 if (!result) {
 [reader cancelReading];
 break;
 }
 
 } else {
 [videoWriterInput markAsFinished];
 
 switch ([reader status]) {
 case AVAssetReaderStatusReading:
 // the reader has more for other tracks, even if this one is done
 break;
 
 case AVAssetReaderStatusCompleted:
 // your method for when the conversion is done
 // should call finishWriting on the writer
 //hook up audio track
 {
 [audioReader startReading];
 [videoWriter startSessionAtSourceTime:kCMTimeZero];
 
 dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
 
 //                         [audioWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^
 //                          {
 //                              NSLog(@"Request");
 //                              NSLog(@"Asset Writer ready :%d",audioWriterInput.readyForMoreMediaData);
 
 //                              while (audioWriterInput.readyForMoreMediaData) {
 //                                  CMSampleBufferRef nextBuffer;
 //
 //                                  if ([audioReader status] == AVAssetReaderStatusReading &&
 //                                      (nextBuffer = [readerOutput copyNextSampleBuffer])) {
 //
 //                                      NSLog(@"Ready");
 //                                      if (nextBuffer) {
 //                                          NSLog(@"NextBuffer");
 //                                          [audioWriterInput appendSampleBuffer:nextBuffer];
 //                                      }
 //
 //                                  }else{
 //                                      [audioWriterInput markAsFinished];
 //                                      switch ([audioReader status]) {
 //                                          case AVAssetReaderStatusCompleted:
 //                                              //                                              [videoWriter finishWriting];
 //                                              //                                              [self hookUpVideo:newName];
 //                                              break;
 //                                      }
 //                                  }
 //                              }
 
 //                          }
 //                          ];
 break;
 }
 case AVAssetReaderStatusFailed:
 {
 [videoWriter cancelWriting];
 break;
 }
 }
 break;
 }
 }
 }
 ];
 NSLog(@"Write Ended");
 }
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
