//
//  WAPhotoViewController.h
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 25/02/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AssetsLibrary/AssetsLibrary.h>

@interface WAPhotoViewController : UIViewController
{
    IBOutlet UICollectionView *imageColectionView;
    IBOutlet UIToolbar *headerToolBar;
    IBOutlet UIBarButtonItem *doneBarButton;
    IBOutlet UIView *overlayView;
    IBOutlet UIActivityIndicatorView *spinner;
    
    ALAssetsLibrary *library;
    NSMutableArray *imageArray;
    NSMutableArray *mutableArray;

}
@property(nonatomic,strong)NSMutableArray *selectedImageArray;

-(IBAction)doneButtonTappedFromToolBar:(id)sender;
-(void)allPhotosCollected:(NSArray*)imgArray;

@end
