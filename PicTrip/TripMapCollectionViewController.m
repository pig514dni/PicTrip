//
//  TripMapCollectionViewController.m
//  PicTrip
//
//  Created by Joe Chen on 2016/6/25.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "TripMapCollectionViewController.h"
#import "TripMapVIewCell.h"
#import <Photos/Photos.h>
#import "TripMapView.h"




@implementation TripMapCollectionViewController

static NSString *const reuseIdentifier = @"Cell";

NSMutableArray *noLocation;
NSArray *modifiedLocationArray;
NSMutableArray *saveSelectPicssss;
- (void)viewDidLoad {
  [super viewDidLoad];
    
    

  self.noLocationAssets = [PHFetchResult new];
  self.noLocationManager = [PHCachingImageManager new];

  self.assets =
      [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
  self.collectionView.backgroundColor = [UIColor whiteColor];
  self.collectionView.delegate = self;

  noLocation = [NSMutableArray new];
  modifiedLocationArray = [NSArray new];
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSArray *modifiedLocation = [userDefaults arrayForKey:@"modifiedLocation"];
  NSMutableArray *selectPicsInfo =
      [userDefaults objectForKey:@"selectPicsInfo"];

  if (modifiedLocation == nil) {
    modifiedLocationArray = [NSArray array];
  } else {
    modifiedLocationArray = [NSArray arrayWithArray:modifiedLocation];
  }
  if (selectPicsInfo == nil) {
    saveSelectPicssss = [NSMutableArray array];
  } else {
    saveSelectPicssss = [NSMutableArray arrayWithArray:selectPicsInfo];
  }    

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(finishLocationModify)
             name:@"finishLocationModify"
           object:nil];

  [self handleNoLocationPics];
    
    
   
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)handleNoLocationPics {

   
        for (int i = 0; i < saveSelectPicssss.count; i++) {
            NSMutableDictionary *temp = [saveSelectPicssss objectAtIndex:i];
            NSString *lat = [temp objectForKey:@"latitude"];
            NSString *lon = [temp objectForKey:@"longtitude"];
            
            if ([lat isEqualToString:@"0.000000"] ||
                [lon isEqualToString:@"0.000000"]) {
                NSLog(@"lat:%@,lon:%@", lat, lon);
                NSNumber *index = [temp objectForKey:@"index"];
                [noLocation addObject:index];
            }
        }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView *)collectionView {

  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {

  return noLocation.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  TripMapVIewCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"TripMapVIewCell"
                                                forIndexPath:indexPath];

  PHFetchOptions *option = [PHFetchOptions new];
  option.sortDescriptors = @[
    [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]
  ];
  self.noLocationAssets =
      [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];

  NSNumber *index = [noLocation objectAtIndex:indexPath.row];

  [self.noLocationManager
      requestImageForAsset:self.noLocationAssets[index.integerValue]
                targetSize:cell.noLocationPics.frame.size
               contentMode:PHImageContentModeAspectFit
                   options:nil
             resultHandler:^(UIImage *_Nullable result,
                             NSDictionary *_Nullable info) {

                 
               cell.noLocationPics.image = result;

             }];

  return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

  PHAsset *selectedPhoto = _noLocationAssets[indexPath.row];
  NSArray *resource = [PHAssetResource assetResourcesForAsset:selectedPhoto];
  NSString *imageName = [resource.firstObject originalFilename];
    NSString * count = [NSString stringWithFormat:@"%lu",(unsigned long)noLocation.count];

  modifiedLocationArray = @[ imageName, noLocation[indexPath.row],count ];

  NSLog(@"%@,%@", modifiedLocationArray[0], modifiedLocationArray[1]);
  [[NSUserDefaults standardUserDefaults] setObject:modifiedLocationArray
                                            forKey:@"modifiedLocation"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  [[NSNotificationCenter defaultCenter]
      postNotificationName:@"modifyLocationControll"
                    object:nil];

  UICollectionViewCell *cell =
      [self.collectionView cellForItemAtIndexPath:indexPath];
  //判斷是否已經加勾勾了
  if (![cell.contentView viewWithTag:123]) {
    UIImage *select = [UIImage imageNamed:@"select.png"];
    UIImageView *se = [[UIImageView alloc] initWithImage:select];
    se.tag = 123;

    [cell.contentView addSubview:se];
  }
}

- (void)collectionView:(UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

  UICollectionViewCell *cell =
      [self.collectionView cellForItemAtIndexPath:indexPath];
  [[cell.contentView viewWithTag:123] removeFromSuperview];
}

- (void)finishLocationModify {
  NSNumber *row = modifiedLocationArray[1];
  NSIndexPath *index =
      [NSIndexPath indexPathForRow:row.integerValue inSection:0];
  UICollectionViewCell *cell =
      [self.collectionView cellForItemAtIndexPath:index];

  cell.selected = NO;
  [noLocation removeObject:modifiedLocationArray[1]];
    
  [self.collectionView reloadData];
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0;
}

//-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    return 2;
//}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 0, 2, 0);
    return insets;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {


    return CGSizeMake(self.view.frame.size.width / 2, self.view.frame.size.height/2);
}

/*
// Uncomment this method to specify if the specified item should be highlighted
during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
        return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for
the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
        return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
withSender:(id)sender {
        return NO;
}

- (void)collectionView:(UICollectionView *)collectionView
performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
withSender:(id)sender {

}
*/

@end
