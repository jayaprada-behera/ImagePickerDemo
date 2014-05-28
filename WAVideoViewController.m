//
//  WAVideoViewController.m
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 03/03/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WAVideoViewController.h"
#import "WAVideoPlayViewController.h"

#define STORY_BOARD_NAME  @"Main"

@interface WAVideoViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation WAVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    videoListTableView.delegate = self;
    videoListTableView.dataSource = self;
    [videoListTableView reloadData];
	// Do any additional setup after loading the view.
}
-(IBAction)doneButtonTappedFromToolBar:(id)sender{

    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITABLEVIEW DATASOURCE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;//self.videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"DetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [NSString stringWithFormat:@"Movie-%d",indexPath.row+1];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORY_BOARD_NAME bundle:nil];
    WAVideoPlayViewController *videoVC = [storyboard instantiateViewControllerWithIdentifier:@"VIDEOPLAYIDENTIFIER"];
    if (self.videoArray.count > 0) {
        
        videoVC.videoURL = [self.videoArray objectAtIndex:indexPath.row];
    }
    [self presentViewController:videoVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
