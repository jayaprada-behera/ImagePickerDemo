//
//  WAVideoViewController.h
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 03/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WAVideoViewController : UIViewController
{
    IBOutlet UITableView *videoListTableView;
    IBOutlet UIToolbar *headerToolBar;
}
@property(nonatomic,strong)NSMutableArray *videoArray;
-(IBAction)doneButtonTappedFromToolBar:(id)sender;

@end
