//
//  WAVideoPlayViewController.h
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 03/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface WAVideoPlayViewController : UIViewController
{
    __weak IBOutlet UIButton *resizeDoneButton;
    __weak IBOutlet UIButton *hdVideoButton;
    __weak IBOutlet UIView *resizeOverlayView;
    IBOutlet UIView *playView;
    __weak IBOutlet UIButton *playVideoButton;
    
    __weak IBOutlet UIButton *goodQualityButton;
    
    __weak IBOutlet UIButton *lessQualityButton;
    __weak IBOutlet UIButton *highQualityButton;
}
- (IBAction)lessQualityButtonTouchUpInside:(id)sender;

- (IBAction)goodQualityButtonTouchUpInside:(id)sender;
- (IBAction)hdVideoButtonTouchUpInside:(id)sender;
- (IBAction)highQualityButtonTouchUpInside:(id)sender;

- (IBAction)resizeDoneButtonTouchUpInside:(id)sender;
- (IBAction)playVideoButtonTouchUpInside:(id)sender;
- (IBAction)resizeButtonTouchUpInside:(id)sender;

-(IBAction)doneButtonTouchUpInside:(id)sender;
@property(nonatomic,strong)NSURL *videoURL;
@end
