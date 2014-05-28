//
//  WAViewController.m
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 24/02/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WAViewController.h"
#import "WAPhotoViewController.h"
#import "WAVideoViewController.h"

#define STORY_BOARD_NAME  @"Main"
#define FB_APP_ID   @"264764970366965"//428897230561539

#define APP_SECRET @"26ef15839cd73ba2cecdf7abb8477b2e"

@interface WAViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UIAlertViewDelegate>{
    NSMutableArray *imageArray ;
    NSMutableArray *selectedImageArray ;
    int _counter;
    UIImagePickerController *imagePicker;
    UIBarButtonItem *imageCountBarButtonItem;
    UIBarButtonItem *flexibleBarSpace;
    UIBarButtonItem *cameraBarButton;
    UIBarButtonItem *cancelBarButton;
    NSMutableArray *videoArray;
    
    BOOL isImage;
    WACapPreview *capPreview;
    NSTimer *pollingTimer;
    int seconds ;
    int minutes;
    
    __weak IBOutlet UILabel *recordingTimer;
}
- (IBAction)makeMovieButtonTouchUpInside:(id)sender;
@end

@implementation WAViewController
@synthesize previewView;
@synthesize scrollImageOverlay;
@synthesize PreviewOverlay;


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [pollingTimer invalidate];
    pollingTimer = nil;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (selectedImageArray == nil) {
        selectedImageArray = [NSMutableArray new];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *logoImage = [UIImage imageNamed:@"navigation-bar-logo.jpg"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logoImage];
    titleLogo.frame = CGRectMake(0, 0, 50, 30);
    
    self.navigationItem.titleView.backgroundColor = [UIColor redColor];

    //Changed orientation on info.plist
    
    isImage = NO;
    
    imageArray = [[NSMutableArray alloc] init];
    if (selectedImageArray == nil) {
        selectedImageArray = [NSMutableArray new];
    }
    videoArray = [NSMutableArray new];
    
    imageScrollView.delegate = self;
    
    capPreview = [[WACapPreview alloc]init];
    
    __weak typeof(self) weakSelf = self;
    
    capPreview.videoRecordingCallBack = ^(NSURL *videoURL){
        [weakSelf storeVideo:videoURL];
    };
    capPreview.imageSnapCallBack = ^(UIImage *image){
        [weakSelf storeImage:image];
    };
    
    [capPreview initializeCaptureSessionOnPreview:self.previewView];
    
    //    [self initializeCapture];
}
-(void)showTimer{
    
    if(seconds >= 59){
        seconds = 0;
        minutes++;
    }
    seconds++;
    recordingTimer.text = [NSString stringWithFormat:@"%d:%d",minutes,seconds];
    //    NSLog(@"%d:%d",minutes,seconds);
    
}
-(void)storeImage:(UIImage *)image{
    
    [selectedImageArray addObject:image];
    [snapImageButton setTitle:[NSString stringWithFormat:@"(%lu)snap",(unsigned long)selectedImageArray.count] forState:UIControlStateNormal];
}
-(NSString *) getDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
-(NSMutableArray *)findFiles:(NSString *)extension {
    
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSString *item;
    
    NSString *documentsDir = [self getDocumentDirectory];
    
    NSArray *contents = [fManager contentsOfDirectoryAtPath:documentsDir error:nil];
    
    // >>> this section here adds all files with the chosen extension to an array
    for (item in contents){
        if ([[item pathExtension] isEqualToString:extension]) {
            [matches addObject:item];
        }
    }
    return matches;
}

-(void)storeVideo:(NSURL *)ref{
    
    [pollingTimer invalidate];
    pollingTimer= nil;
    recordButton.enabled = YES;
    if (![videoArray containsObject:ref]) {
        [videoArray addObject:ref];
    }
    scrollImageOverlay.hidden = YES;
    self.PreviewOverlay.hidden = NO;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [self.videoButton setTitle:[NSString stringWithFormat:@"(%lu)show Video",(unsigned long)videoArray.count] forState:UIControlStateNormal];
    
}

#pragma mark - UIBUTTON ACTIONS
- (IBAction)showSelectedPhotosButtonTouchUpInside:(id)sender {
    
    if (selectedImageArray.count == 0) {
        [[[UIAlertView alloc]initWithTitle:@"No photos selected" message:@"" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil]show];
    }else{
        imagePagecontrol.numberOfPages = selectedImageArray.count;
        [self addImagesToScrollViewForArray:selectedImageArray];
    }
}

- (IBAction)RecordVideoButtonTouchUpInside:(id)sender{
    
    [[[UIAlertView alloc]initWithTitle:@"Choose" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"AVFoundation",@"ImagePicker", nil]show];
}
- (IBAction)showVideoButtonTouchUpInside:(id)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:nil];
    WAVideoViewController *videoVC = [storyboard instantiateViewControllerWithIdentifier:@"VIDEOIDENTIFIER"];
    videoVC.videoArray = videoArray;
    [self presentViewController:videoVC animated:YES completion:nil];
    
}

- (IBAction)recordButtonTouchUpInside:(id)sender {
    UIButton *b = sender;
    recordButton.enabled = NO;
    recordingTimer.hidden = NO;
    pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(showTimer)
                                                  userInfo:nil
                                                   repeats:YES];
    [capPreview recordButton:b];
}

- (IBAction)snapButtonTouchUpInside:(id)sender {
    recordingTimer.hidden = YES;
    UIButton *b = sender;
    [capPreview snapButton:b];
}

- (IBAction)cameraToggleButtonTouchUpInside:(id)sender {
    recordingTimer.hidden = YES;
    UIButton *b = sender;
    [capPreview changeCameraButton:b];
}

-(void)takePicture{
    [imagePicker takePicture];
}

-(void)cancelImagePicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)tapToSelectImage:(id)sender{
    
    //storyboard name is mentioned in info.plist
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:nil];
    WAPhotoViewController *photoVC = [storyboard instantiateViewControllerWithIdentifier:@"IDENTIFIER"];
    photoVC.selectedImageArray = selectedImageArray;
    [self presentViewController:photoVC animated:YES completion:nil];
}

-(IBAction)tapToUploadImage:(id)sender{
    
    isImage = YES;
    _counter=0;
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
        imagePicker.toolbarHidden = NO;
        imagePicker.toolbar.tintColor = [UIColor blackColor];
        imagePicker.showsCameraControls = NO;
        
        //To remove black bottom bar in camera for iphone
        
        CGAffineTransform cameraTransform = CGAffineTransformMakeScale(1.23, 1.5);
        imagePicker.cameraViewTransform = cameraTransform;
        
        imageCountBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"0" style:UIBarButtonItemStyleBordered target: self action:nil];
        flexibleBarSpace= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        cameraBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture)];
        cancelBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelImagePicker)];
    }
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    [self presentViewController:imagePicker animated:YES completion:^{
            imagePicker.toolbar.items = [NSArray arrayWithObjects:cameraBarButton,flexibleBarSpace,cancelBarButton, nil];
    }];
}
- (IBAction)makeMovieButtonTouchUpInside:(id)sender {
    if (selectedImageArray.count == 0) {
        [[[UIAlertView alloc]initWithTitle:@"please select at least one image" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        return;
    }
    
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"30secs" ofType:@"mp3"];
    
    NSString *videoPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"test_output.mp4"]];
    
    NSString *finalVideoFilePath = [documentsDirectory stringByAppendingPathComponent:@"final_video.mp4"];
    
    UIImage *img = [selectedImageArray objectAtIndex:0];
    
    NSLog(@"h:%@,w:%@",[NSNumber numberWithFloat:img.size.height],[NSNumber numberWithFloat:img.size.width]);
    
    [self writeImageAndAudioAsMovie:img andVideoPath:videoPath andAudio:audioFilePath andFinalVideoPath:finalVideoFilePath duration:30];
    
}
#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (isImage) {
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        [imageArray addObject:chosenImage];
        _counter++;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            [imageCountBarButtonItem setTitle:[NSString stringWithFormat:@"(%d)",_counter]];
        
        if ( _counter < 5){
            
            [self dismissViewControllerAnimated:NO completion:^{}];
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                
                [self presentViewController:imagePicker animated:NO completion:^{
                    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
                        imagePicker.toolbar.items =  [NSArray arrayWithObjects:imageCountBarButtonItem, flexibleBarSpace,cameraBarButton,flexibleBarSpace,cancelBarButton, nil];;
                }];
            }
        }else{
            imagePagecontrol.numberOfPages = imageArray.count;
            [self dismissViewControllerAnimated:YES completion:nil];
            [self addImagesToScrollViewForArray:imageArray];
            imagePicker = nil;
        }
        
    }else{
        
        NSDictionary *dict = info;
        NSString *urlStr = [dict objectForKey:UIImagePickerControllerMediaURL];
        if (![videoArray containsObject:urlStr]) {
            
            [videoArray  addObject:urlStr];
        }
        
        [self.videoButton setTitle:[NSString stringWithFormat:@"(%lu)show Video",(unsigned long)videoArray.count] forState:UIControlStateNormal];
        [self dismissViewControllerAnimated:YES completion:nil];
        imagePicker = nil;
        
    }
    self.scrollImageOverlay.hidden = NO;
    self.PreviewOverlay.hidden = YES;
    
}
-(void)addImagesToScrollViewForArray:(NSArray *)array{
    
    self.PreviewOverlay.hidden = YES;
    scrollImageOverlay.hidden = NO;
    imageScrollView.contentSize = CGSizeMake(imageScrollView.frame.size.width *array.count, imageScrollView.frame.size.height);
    int x = 0;
    for (int i = 0; i<array.count; i++) {
        x = imageScrollView.frame.size.width * i;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(x, 0, imageScrollView.frame.size.width, imageScrollView.frame.size.height)] ;
        [imageView setImage: [array objectAtIndex:i]];
        [imageScrollView addSubview: imageView];
    }
}

#pragma mark - UIScrollViewDelegates

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    imagePagecontrol.currentPage=page;
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == alertView.cancelButtonIndex) {
    }else if(buttonIndex == 1){
        
        self.scrollImageOverlay.hidden = YES;
        self.PreviewOverlay.hidden = NO;
        
    }else if(buttonIndex == 2){
        
        self.PreviewOverlay.hidden = YES;
        isImage = NO;
        imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}


- (void)video:(NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    NSString *path1 = [url path];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path1];
    NSLog(@"size of video is %lu",(unsigned long)data.length);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"Video could not be saved ,Error:%@",error);
            [[[UIAlertView alloc]initWithTitle:@"Sorry!!" message:@"Video data is Nil" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];

        }else{
            if (![videoArray containsObject:url]) {
                [videoArray addObject:url];
            }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Done"
                                                       message:@"Movie succesfully exported."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        }
    }];
}
//http://stackoverflow.com/questions/5640657/avfoundation-assetwriter-generate-movie-with-images-and-audio
//http://stackoverflow.com/questions/9562639/issue-in-generating-a-video-from-array-of-images?rq=1
//https://github.com/caferrara/img-to-video

- (void)writeImageAndAudioAsMovie:(UIImage*)image andVideoPath:(NSString *)videoPath andAudio:(NSString *)audioFilePath andFinalVideoPath:(NSString *)finalVideoPath duration:(int)duration {
    
    
    NSLog(@"start make movie: length:%d",duration);
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:videoPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    NSParameterAssert(videoWriter);
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]){//ImageVideoPath
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
    }
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:image.size.width],AVVideoWidthKey,
                                   [NSNumber numberWithInt:image.size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                       assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    writerInput.expectsMediaDataInRealTime = YES;
    [videoWriter setShouldOptimizeForNetworkUse:YES];
    [videoWriter addInput:writerInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    NSUInteger fps = 30;
    
    int frameCount = 0;
    double numberOfSecondsPerFrame = 6;
    double frameDuration = fps * numberOfSecondsPerFrame;
    
    for(UIImage * img in selectedImageArray)
    {
        buffer = [self pixelBufferFromCGImage:[img CGImage]];
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
                //print out status:
                NSLog(@"Processing video frame (%d,%d)",frameCount,[imageArray count]);
                
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok){
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            printf("error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
    }
    //Finish the session:
    [videoWriter endSessionAtSourceTime:CMTimeMake(60*8, 1)];//give a user defined duration and endthe session
    [writerInput markAsFinished];
    NSURL *refURL = [[NSURL alloc] initFileURLWithPath:videoPath];
    [videoArray addObject:refURL];
    
    //get the iOS version of the device
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version < 6.0){
        [videoWriter finishWriting];
        NSLog (@"finished writing iOS version:%f",version);
    } else {
        [videoWriter finishWritingWithCompletionHandler:^(){
            NSLog (@"finished writing iOS version:%f",version);
        }];
    }
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
    [self addAudioToFileAtPath:audioFilePath toVideoPath:videoPath andFinalVideoPath:finalVideoPath];
}
- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image{
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

//http://stackoverflow.com/questions/5640657/avfoundation-assetwriter-generate-movie-with-images-and-audio

-(void) addAudioToFileAtPath:(NSString *) audiofilePath toVideoPath:(NSString *)videoFilePath andFinalVideoPath:(NSString *)finalVideoPath
{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    // audio input file...
    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:audiofilePath];
    
    // this is the video file that was just written above, full path to file is in --> videoOutputPath
    NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:videoFilePath];
    
    // create the final video output file as MOV file - may need to be MP4, but this works so far...
    NSURL    *outputFileUrl = [NSURL fileURLWithPath:finalVideoPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:finalVideoPath])
        [[NSFileManager defaultManager] removeItemAtPath:finalVideoPath error:nil];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    //_assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputFileType = @"public.mpeg-4";
    //NSLog(@"support file types= %@", [_assetExport supportedFileTypes]);
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         switch (_assetExport.status)
         {
             case AVAssetExportSessionStatusCompleted:
                 //                export complete
                 NSLog(@"Export Complete");
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Export Failed");
                 NSLog(@"ExportSessionError: %@", [_assetExport.error localizedDescription]);
                 //                export error (see exportSession.error)
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Export Failed");
                 NSLog(@"ExportSessionError: %@", [_assetExport.error localizedDescription]);
                 //                export cancelled
                 break;
         }
         //If you want to save the video to Photo Album
         UISaveVideoAtPathToSavedPhotosAlbum (finalVideoPath,self, @selector(video:didFinishSavingWithError: contextInfo:), nil);
     }
     ];
    
    ///// THAT IS IT DONE... the final video file will be written here...
    NSLog(@"DONE.....outputFilePath--->%@", finalVideoPath);
    
    // the final video file will be located somewhere like here:
    // /Users/caferrara/Library/Application Support/iPhone Simulator/6.0/Applications/D4B12FEE-E09C-4B12-B772-7F1BD6011BE1/Documents/outputFile.mov
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
