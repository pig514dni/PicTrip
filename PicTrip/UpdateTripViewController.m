//
//  UpdateTripViewController.m
//  PicTrip
//
//  Created by Joe Chen on 2016/6/17.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "UpdateTripViewController.h"
#import "updateTripPicsCollectionViewCell.h"
#import "TripMapView.h"
#import <Photos/PHPhotoLibrary.h>
#import "PTCommunicator.h"
#import "CollectionHeaderView.h"
#import "ImageScale.h"


@import Photos;

@interface UpdateTripViewController ()<UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate,UICollectionViewDelegateFlowLayout>
{
    PTCommunicator * comm;
    CollectionHeaderView  * header;
}
@property (weak, nonatomic) IBOutlet UICollectionView *selectedPicsCollection;
@property (weak, nonatomic) IBOutlet UITextField *tourName;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong) PHFetchResult *assets;
@property (strong) PHCachingImageManager *manager;
@property (strong,nonatomic) NSString *userID;

@end

@implementation UpdateTripViewController
static NSString * const reuseIdentifier = @"Cell";
NSMutableArray * indexPics;
NSMutableArray * saveLocationPics;
NSMutableArray * saveSelectPicss;
NSUserDefaults * tripPicsDefaults;
UIImage * image;
NSMutableArray * selectPicsInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //look up user_id from userDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _userID = [userDefaults objectForKey:@"user_id"];
    //remember to do something if user_id doesnt exist or is @"guest"
    
    _descriptionTextView.delegate = self;
    _descriptionTextView.text = @"想說些什麼呢！";
    _descriptionTextView.textColor = [UIColor lightGrayColor]; //optional
    [_tourName setDelegate:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
  
    _assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    _manager = [PHCachingImageManager new];
    image = [UIImage new];
    comm = [PTCommunicator sharedInstance];

    
    self.manager = [[PHCachingImageManager alloc]init];
    self.assets = [PHAsset fetchAssetsWithOptions:nil];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.selectedPicsCollection.backgroundColor = [UIColor whiteColor];
    
    indexPics = [[NSMutableArray alloc]init];
    saveSelectPicss = [NSMutableArray new];
    
    tripPicsDefaults = [NSUserDefaults standardUserDefaults];
    [tripPicsDefaults removeObjectForKey:@"selectPicsInfo"];
    [tripPicsDefaults removeObjectForKey:@"noLocationDafault"];
    
    [self.selectedPicsCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCollectionView) name:@"imageIndexUpdated" object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [_tourName resignFirstResponder];
    [_descriptionTextView resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"想說些什麼呢！"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"想說些什麼呢！";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([_descriptionTextView isFirstResponder] && [touch view] != _descriptionTextView) {
//        [_descriptionTextView resignFirstResponder];
//    }
//    [super touchesBegan:touches withEvent:event];
//}

- (IBAction)performMapView:(UIButton *)sender {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    selectPicsInfo = [userDefaults objectForKey:@"selectPicsInfo"];
    
    if(selectPicsInfo.count == 0){
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Notice!" message:@"Please select photos first" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            
        }];
        
        [alertController addAction:action];

        [self presentViewController:alertController animated:true completion:nil];

        
    }else{
        TripMapView * vc = (TripMapView*)[self.storyboard instantiateViewControllerWithIdentifier:@"TripMapView"];
        
        [self presentViewController:vc animated:YES completion:nil];

    }
    
    
}
- (IBAction)uploadToserver:(id)sender {

    NSDictionary * tour = [comm generateTourInfoWithUerID:_userID tourname:_tourName.text description:_descriptionTextView.text];
    NSLog(@"%@",tour);
    
    [comm createTourWithTourInfo:tour completion:^(NSError *error, id result) {
        if(error){
            NSLog(@"error");
        }else{
            NSString * tourID = [result objectForKey:@"id"];
            [self uploadPhotosTosServer:tourID];
        }
       // NSLog(@"%@",result);
    }];
}

-(void)uploadPhotosTosServer:(NSString*)tourID{
    
    NSMutableArray * selectPicsInfo = [tripPicsDefaults objectForKey:@"selectPicsInfo"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    for(int i = 0 ; i < selectPicsInfo.count ; i++){
        
        NSMutableDictionary * temp = [selectPicsInfo objectAtIndex:i];
        NSNumber * index = [temp objectForKey:@"index"];
        NSString * imageName = [temp objectForKey:@"name"];
        PHAsset * asset = _assets[index.integerValue];
        NSNumber* lat = [temp objectForKey:@"latitude"];
        NSNumber* lon = [temp objectForKey:@"longitude"];
        NSDate * createDate = asset.creationDate ;
        NSTimeInterval since = [createDate timeIntervalSince1970];
        // NSDate * timeSince1970 = [[NSDate alloc]initWithTimeIntervalSince1970:since];
        
        
        NSDictionary * imageInfo =[comm generateImageInfoWithUserID:_userID filename:imageName tourID:tourID description:@"" time:since lat:[NSString stringWithFormat:@"%@",lat] lon:[NSString stringWithFormat:@"%@",lon]];
        
        
        [self.manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            result = [result imageScaledToQuarter];
            image = result;
            
            [comm uploadImageWithImage:image imageInfo:imageInfo completion:^(NSError *error, id result) {
                
                if(error){
                    NSLog(@"Upload image error");
                }
            }];
        }];
    }
}

-(void)updateCollectionView{
    
    NSMutableArray * selectPicsInfo = [tripPicsDefaults objectForKey:@"selectPicsInfo"];
    [saveSelectPicss removeAllObjects];
    
    saveSelectPicss = [NSMutableArray arrayWithArray:selectPicsInfo];
    
    [self.selectedPicsCollection reloadData ];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return saveSelectPicss.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    updateTripPicsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"updateTripPicsCollectionViewCell" forIndexPath:indexPath];
    CGSize imgSize = [self imageSize:indexPath];
    
    PHFetchOptions * option= [PHFetchOptions new];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    
        NSMutableDictionary * tempDic = [saveSelectPicss objectAtIndex:indexPath.row];
    NSNumber * index = [tempDic objectForKey:@"index"];
    
    [self.manager requestImageForAsset:self.assets[index.integerValue] targetSize:imgSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        

        cell.pics.bounds = CGRectMake(0, 0, imgSize.width, imgSize.height);
        cell.pics.image = result;
    }];
    
    UIButton * delete = [UIButton buttonWithType:UIButtonTypeCustom];
    [delete addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    delete.tag = index.integerValue;
    [delete setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    delete.frame = CGRectMake(cell.frame.size.width-30, 5, 20, 20);
    [cell.contentView addSubview:delete];
    
    return cell;
}

-(CGSize)imageSize:(NSIndexPath *)indexPath{
    
    
    PHAsset * img = self.assets[indexPath.row];
    NSInteger screenWidth = 375;
    double scale = img.pixelWidth / screenWidth;
    CGFloat scaledHeight = (img.pixelHeight) / ( scale);
    CGSize  imgSize =  CGSizeMake(375, scaledHeight);
    NSLog(@"%f,%f",imgSize.width,imgSize.height);
    return imgSize;
}
//
//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    PHAsset * ass = self.assets[indexPath.row];
//    NSLog(@"%lu,%lu",(unsigned long)ass.pixelWidth,(unsigned long)ass.pixelHeight);
//    
//    NSInteger screenWidth = 375;
//    double scale = ass.pixelWidth / screenWidth;
//    CGFloat scaledHeight = (ass.pixelHeight) / ( scale);
//    CGSize  scaledSize =  CGSizeMake(375, scaledHeight);
//    
//    NSLog(@"%f,%f",scaledSize.width,scaledSize.height);
//    return scaledSize;
//    
//}

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
    
    [self.selectedPicsCollection reloadData];
    
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

@end
