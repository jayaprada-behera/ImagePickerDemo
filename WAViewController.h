//
//  WAViewController.h
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 24/02/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "WACapPreview.h"

@interface WAViewController : UIViewController
{
    IBOutlet UIButton *uploadImageButton;
    IBOutlet UIScrollView *imageScrollView;
    IBOutlet UIPageControl *imagePagecontrol;
    
    __weak IBOutlet UIButton *showSelectedPhotosButton;
    __weak IBOutlet UIButton *recordButton;
    __weak IBOutlet UIButton *snapImageButton;
}
@property(weak,nonatomic)IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIView *scrollImageOverlay;
@property (weak, nonatomic) IBOutlet UIView *PreviewOverlay;

-(IBAction)showSelectedPhotosButtonTouchUpInside:(id)sender;
- (IBAction)RecordVideoButtonTouchUpInside:(id)sender;
- (IBAction)showVideoButtonTouchUpInside:(id)sender;

- (IBAction)recordButtonTouchUpInside:(id)sender;
- (IBAction)snapButtonTouchUpInside:(id)sender;
- (IBAction)cameraToggleButtonTouchUpInside:(id)sender;

-(IBAction)tapToUploadImage:(id)sender;
-(IBAction)tapToSelectImage:(id)sender;

@end
