//
//  WAPhotoViewController.m
//  MultipleImageClick
//
//  Created by Jayaprada Behera on 25/02/14.
//  Copyright (c) 2014 Webileapps. All rights reserved.
//

#import "WAPhotoViewController.h"
#import "WAPhotoCell.h"

@interface WAPhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@end

@implementation WAPhotoViewController
@synthesize selectedImageArray;
static NSInteger count=0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    imageArray = [NSMutableArray new];
    [imageColectionView registerClass:[WAPhotoCell class] forCellWithReuseIdentifier:@"photoCell"];
//  /Users/Manoj/Development/Demo projects/ImagePickerDemo/ImagePickerDemo/WAPhotoViewController.m  
    UINib *nib = [UINib nibWithNibName:@"WAPhotoCell" bundle: nil];
    [imageColectionView registerNib:nib forCellWithReuseIdentifier:@"photoCell"];
    
    imageColectionView.dataSource = self;
    imageColectionView.delegate = self;
    [spinner startAnimating];
    
    [self getAllPictures];
}
-(void)getAllPictures
{
       mutableArray =[[NSMutableArray alloc]init];
       [mutableArray removeAllObjects];
       [imageArray removeAllObjects];
        
       NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    
       library = [[ALAssetsLibrary alloc] init];
     
       void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
            if(result != nil) {
                if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    
                    NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                    
                    [library assetForURL:url
                             resultBlock:^(ALAsset *asset) {
                                     @autoreleasepool {
                                         
                                         UIImage *imageToSave = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                                         CGSize sizeToSave = CGSizeMake(400,200);
                                         UIGraphicsBeginImageContextWithOptions(sizeToSave, NO, 0.f);
                                         [imageToSave drawInRect:CGRectMake(0.f, 0.f, sizeToSave.width, sizeToSave.height)];
                                         UIImage *finalImageToSave = UIGraphicsGetImageFromCurrentImageContext();
                                         UIGraphicsEndImageContext();
                                         
                                         NSLog(@"mutableArray.count:%d",mutableArray.count);
                                       
                                         if (finalImageToSave!=nil) {
                                             [mutableArray addObject:finalImageToSave];
                                         }
                                         if ([mutableArray count]==70)//count
                                         {
                                             [imageArray addObjectsFromArray:mutableArray];
                                             [self allPhotosCollected:imageArray];
                                         }
                                     }
                             }
                            failureBlock:^(NSError *error){
                                [[[UIAlertView alloc]initWithTitle:@"" message:@"operation was not successfull!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                                NSLog(@"operation was not successfull!");
                            } ];
                }
            }else{
                
                //handle UI
            }
      };
    
       NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
      void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
         if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
            count=[group numberOfAssets];
        }
      };
    
      assetGroups = [[NSMutableArray alloc] init];
    
      [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {
                             [[[UIAlertView alloc]initWithTitle:@"" message:@"There is an error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                         }];
    }

-(void)allPhotosCollected:(NSArray*)imgArray
{
    //write your code here after getting all the photos from library...
    
    [overlayView removeFromSuperview];
    overlayView.hidden = YES;
    [imageColectionView reloadData];
    [spinner stopAnimating];
    NSLog(@"all pictures are %@",imgArray);
    
}
-(IBAction)doneButtonTappedFromToolBar:(id)sender{

    if (selectedImageArray.count > 0) {
        
        UIImage *img = [selectedImageArray objectAtIndex:0];
        NSLog(@"h:%@,w:%@",[NSNumber numberWithFloat:img.size.height],[NSNumber numberWithFloat:img.size.width]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //    NSString *searchTerm = self.searches[section];
    return imageArray.count;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WAPhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    //    NSLog(@"%@",[imageArray objectAtIndex:indexPath.row]);
    cell.imageView_ .image =[imageArray objectAtIndex:indexPath.row];
    return cell;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    if ( ![selectedImageArray containsObject:[imageArray objectAtIndex:indexPath.row]]) {
        [selectedImageArray addObject:[imageArray objectAtIndex:indexPath.row]];
    }
    
    WAPhotoCell *cell=(WAPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.overlayImageView_.hidden = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
