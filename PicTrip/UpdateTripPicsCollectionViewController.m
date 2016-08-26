//
//  UpdateTripPicsCollectionViewController.m
//  PicTrip
//
//  Created by Joe Chen on 2016/6/17.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "UpdateTripPicsCollectionViewController.h"
#import "updateTripPicsCollectionViewCell.h"
#import <Photos/PHPhotoLibrary.h>
#import <QuartzCore/QuartzCore.h>



@import Photos;

@interface UpdateTripPicsCollectionViewController ()


@property (strong) PHFetchResult *assets;
@property (strong) PHCachingImageManager *manager;
@end

@implementation UpdateTripPicsCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
NSMutableArray * indexPics;
NSMutableArray * saveLocationPics;
NSMutableArray * saveSelectPicss;
NSUserDefaults * tripPicsDefaults;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[PHCachingImageManager alloc]init];
    self.assets = [PHAsset fetchAssetsWithOptions:nil];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    indexPics = [[NSMutableArray alloc]init];
    saveSelectPicss = [NSMutableArray new];
    
    tripPicsDefaults = [NSUserDefaults standardUserDefaults];
    [tripPicsDefaults removeObjectForKey:@"selectPicsInfo"];
    [tripPicsDefaults removeObjectForKey:@"noLocationDafault"];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCollectionView) name:@"imageIndexUpdated" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateCollectionView{
    
    NSMutableArray * selectPicsInfo = [tripPicsDefaults objectForKey:@"selectPicsInfo"];
    [saveSelectPicss removeAllObjects];
    
    saveSelectPicss = [NSMutableArray arrayWithArray:selectPicsInfo];

    [self.collectionView reloadData ];
    
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

    return saveSelectPicss.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    updateTripPicsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"updateTripPicsCollectionViewCell" forIndexPath:indexPath];

    
    PHFetchOptions * option= [PHFetchOptions new];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    
    NSMutableDictionary * tempDic = [saveSelectPicss objectAtIndex:indexPath.row];
    NSNumber * index = [tempDic objectForKey:@"index"];
    
    [self.manager requestImageForAsset:self.assets[index.integerValue] targetSize:cell.pics.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        
        cell.pics.image = result;
    }];

    UIButton * delete = [UIButton buttonWithType:UIButtonTypeCustom];
    [delete addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    delete.tag = index.integerValue;
    [delete setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    delete.frame = CGRectMake(cell.frame.size.width-35, 0, 32, 32);
    [cell.contentView addSubview:delete];
    
    return cell;
}

-(IBAction)deleteBtnClick:(UIButton*)button{

    NSNumber * deleteIndex = [NSNumber numberWithInteger:button.tag];
    saveSelectPicss = [[tripPicsDefaults objectForKey:@"selectPicsInfo"]mutableCopy];
    
    for(int a = 0 ; a < saveSelectPicss.count ; a++){
        NSLog(@"%@",saveSelectPicss);
        NSMutableDictionary * temp = [saveSelectPicss objectAtIndex:a];
        NSNumber * tempIndex = [temp objectForKey:@"index"];
        if(tempIndex.integerValue == deleteIndex.integerValue ){
            [saveSelectPicss removeObjectAtIndex:a];
        }
    }
    
    NSLog(@"%@",saveSelectPicss);
    [[NSUserDefaults standardUserDefaults] setObject:saveSelectPicss forKey:@"selectPicsInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.collectionView reloadData];
    
   // NSLog(@"%ld",(long)butten.tag);
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 2;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 0, 3, 0);
    return insets;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    
//    return CGSizeMake(self.view.frame.size.width / 2.03, self.view.frame.size.height/2);
//}



#pragma mark <UICollectionViewDelegate>




/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

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
