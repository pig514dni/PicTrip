//
//  PicsCollectionController.m
//  Pictrip
//
//  Created by Joe Chen on 2016/6/15.
//  Copyright © 2016年 Joe Chen. All rights reserved.
//

#import "PicsCollectionController.h"
#import "PiscCollectionViewCell.h"
#import <Photos/PHPhotoLibrary.h>
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"

@import Photos;


@interface PicsCollectionController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong) PHCachingImageManager *manager;
@property (strong) PHFetchResult *assets;

@end

@implementation PicsCollectionController

NSMutableArray * noLocationPics;
NSMutableArray * saveSelectPics;
static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    saveSelectPics = [NSMutableArray new];
    
    self.manager = [PHCachingImageManager new];

    
    PHFetchOptions * option= [PHFetchOptions new];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

    self.assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
      // Register cell classes
//  [self.collectionView registerClass:[PiscCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.allowsMultipleSelection = true;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    
 
    noLocationPics = [NSMutableArray new];

    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * noLocationDafault = [userDefaults objectForKey:@"noLocationDafault"];
    NSMutableArray * selectPicsInfo = [[userDefaults objectForKey:@"selectPicsInfo"] mutableCopy];
    

    if (noLocationDafault == nil) {
        noLocationPics = [NSMutableArray array];
    } else {
        noLocationPics = [NSMutableArray arrayWithArray:noLocationDafault];
    }
    if (selectPicsInfo == nil) {
        saveSelectPics = [NSMutableArray array];
    } else {
        saveSelectPics = [NSMutableArray arrayWithArray:selectPicsInfo];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PiscCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PiscCollectionViewCell" forIndexPath:indexPath];
    
    [self.manager requestImageForAsset:self.assets[indexPath.row] targetSize:cell.pics.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
    
        cell.pics.image = result;
        
    
    }];
    
    //一進來collectionView時先把全部的溝溝圖示清掉 下面code再來判斷哪些cell要加入勾勾
    [[cell.contentView viewWithTag:123]removeFromSuperview];

    NSNumber * index = [[NSNumber alloc]initWithDouble:indexPath.row];

    for(int a = 0 ; a < saveSelectPics.count ; a++){
        NSMutableDictionary * temp = [saveSelectPics objectAtIndex:a];
        NSNumber * tempIndex = [temp objectForKey:@"index"];
        if(tempIndex.integerValue == index.integerValue ){
            
            UIImage * select = [UIImage imageNamed:@"select.png"];
            UIImageView * se = [[UIImageView alloc]initWithImage:select];
            se.tag =123;
            
            [cell.contentView addSubview:se];
            cell.selected = YES;
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }

    return cell;
}


#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PHAsset * selectPic = self.assets[indexPath.row];
    NSNumber * index = [[NSNumber alloc]initWithDouble:indexPath.row];
 //-----------------
    NSArray * resource = [PHAssetResource assetResourcesForAsset:selectPic];
    NSString * imageName =[resource.firstObject originalFilename];
    
    NSString * lat = [NSString stringWithFormat:@"%f",selectPic.location.coordinate.latitude];
    NSString * lon = [NSString stringWithFormat:@"%f",selectPic.location.coordinate.longitude];

    //saveSelectPicsInfo = @{@"index":index,@"name":imageName,@"latitude":lat,@"longitude":lon};
    NSMutableDictionary * saveSelectPicsInfo = [[NSMutableDictionary alloc]init];
    [saveSelectPicsInfo setObject:index forKey:@"index"];
    [saveSelectPicsInfo setObject:imageName forKey:@"name"];
    [saveSelectPicsInfo setObject:lat forKey:@"latitude"];
    [saveSelectPicsInfo setObject:lon forKey:@"longitude"];
   
    [saveSelectPics addObject:saveSelectPicsInfo];
    
    [[NSUserDefaults standardUserDefaults] setObject:saveSelectPics forKey:@"selectPicsInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
 //-----------------

    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"imageIndexUpdated" object:nil];
    
    UICollectionViewCell* cell=[self.collectionView cellForItemAtIndexPath:indexPath];
    UIImage * select = [UIImage imageNamed:@"select.png"];
    UIImageView * se = [[UIImageView alloc]initWithImage:select];
    se.tag =123;
    
    [cell.contentView addSubview:se];
   
}

-(BOOL)collectionView:(UICollectionView *)collectionView canFocusItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSNumber * index = [[NSNumber alloc]initWithDouble:indexPath.row];
    
     //-----------------
    for(int a = 0 ; a < saveSelectPics.count ; a++){
        NSMutableDictionary * temp = [saveSelectPics objectAtIndex:a];
        NSNumber * tempIndex = [temp objectForKey:@"index"];
        if(tempIndex.integerValue == indexPath.row ){
            [saveSelectPics removeObjectAtIndex:a];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:saveSelectPics forKey:@"selectPicsInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"imageIndexUpdated" object:nil];
     //-----------------
    
    for(int i=0;i<noLocationPics.count;i++){
        if(index == noLocationPics[i]){
            [noLocationPics removeObject:index];
            
            [[NSUserDefaults standardUserDefaults] setObject:noLocationPics forKey:@"noLocationDafault"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    UICollectionViewCell* cell=[self.collectionView cellForItemAtIndexPath:indexPath];
    [[cell.contentView viewWithTag:123]removeFromSuperview];
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 2;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    UIEdgeInsets insets = UIEdgeInsetsMake(3, 3, 3, 3);
    return insets;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.view.frame.size.width / 3.1, self.view.frame.size.height/5.2);
}


//// Uncomment this method to specify if the specified item should be highlighted during tracking
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//	return YES;
//}



// Uncomment this method to specify if the specified item should be selected
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}




/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
