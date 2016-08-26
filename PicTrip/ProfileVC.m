//
//  ProfileVC.m
//  PicTrip
//
//  Created by 塗政勳 on 2016/6/19.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "ProfileVC.h"
#import "ProfileVCTourCell.h"
#import "ProfileVCImageCell.h"
#import "ProfileVCProfileCell.h"
#import "PTCommunicator.h"
#import "Tour.h"
#import "TourViewController.h"
#import "ImageViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImageScale.h"
#import "CacheManager.h"

@interface ProfileVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *followerNumber;
@property (weak, nonatomic) IBOutlet UITextView *intro;
@property (weak, nonatomic) IBOutlet UICollectionView *tourCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *editProfileImageBtn;

@property (strong,nonatomic) PTCommunicator *comm;
@property (strong,nonatomic) CacheManager *manager;
@property (strong,nonatomic) UICollectionView *imageCollectionView;
@property (strong,nonatomic) UITableView *profileTableView;
@property (strong,nonatomic) NSMutableDictionary *targetUserInfo;
@property (strong,nonatomic) NSMutableArray *tourInfoArray;
@property (strong,nonatomic) NSMutableArray *imageInfoArray;
@property (nonatomic,strong) NSString *userid;
@property (nonatomic) dispatch_once_t setupCVToken;
@property (nonatomic) dispatch_once_t setupCVTokenI;
@property (nonatomic) dispatch_once_t setupCVTokenII;

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _comm = [PTCommunicator sharedInstance];
    _manager = [CacheManager new];
    
    if (!_targetUserID) {
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        _userid = [userdefault objectForKey:@"user_id"];
        _targetUserID = _userid;
        UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(navigationEdit)];
        self.navigationItem.rightBarButtonItem = editBtn;
        _editProfileImageBtn.hidden = NO;
    }
    
    [_comm getUserInfoWithUserID:_targetUserID completion:^(NSError *error, id result) {
        _targetUserInfo = [NSMutableDictionary dictionaryWithDictionary:result[@"userInfo"]];
        _username.text = _targetUserInfo[@"profile_name"];
        _intro.text = _targetUserInfo[@"introduction"];
        
        [_comm downloadProfileImageWithImageID:_targetUserInfo[@"profile_image_id"] completion:^(NSError *error, id result) {
            _userImage.image = result;
            
        }];
    }];
    _setupCVToken = _setupCVTokenI = _setupCVTokenII = 0;
    
}

-(void)dealloc{
    NSLog(@"ProfileVC dealloc");
}

- (void)navigationEdit{
    NSLog(@"edit pressed.");
}

-(void)setupCollectionViewData{
    if (_segment.selectedSegmentIndex == 0) {
        
        dispatch_once(&_setupCVToken, ^{
            
            _tourCollectionView.tag = 10;
            _tourInfoArray = [NSMutableArray new];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:[_targetUserInfo[@"tours_id"] componentsSeparatedByString:@","]];
            [array removeLastObject];
            __block int count = 0;
                for (int i=0;i<array.count;i+=1) {
                    [_tourInfoArray addObject:[NSNull null]];
                    [_comm getTourInfoWithTourID:array[i] completion:^(NSError *error, id result) {
                        Tour *tour = [Tour tourWithTourInfo:result[@"tourInfo"]];
                                _tourInfoArray[i] = tour;
                        count += 1;
                        if (count == array.count) {
//                            NSLog(@"tourInfoArray: %@",_tourInfoArray);
                            [_tourCollectionView reloadData];
                        }
                    }];
                }
        });

        _tourCollectionView.hidden = NO;
        _imageCollectionView.hidden = YES;
        _profileTableView.hidden = YES;
      
    } else if (_segment.selectedSegmentIndex == 1) {
        
        dispatch_once(&_setupCVTokenI, ^{
            
            UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
            
            _imageCollectionView = [[UICollectionView alloc]initWithFrame:_tourCollectionView.frame collectionViewLayout:layout];
            
            
            [_imageCollectionView setDataSource:self];
            [_imageCollectionView setDelegate:self];
            
            [_imageCollectionView registerClass:NSClassFromString(@"ProfileVCImageCell") forCellWithReuseIdentifier:@"ImageCell"];
            
            _imageInfoArray = [NSMutableArray arrayWithArray:[_targetUserInfo[@"images_id"] componentsSeparatedByString:@","]];
            [_imageInfoArray removeLastObject];
            _imageCollectionView.tag = 20;
            _imageCollectionView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:_imageCollectionView];

        });
        
        _tourCollectionView.hidden = YES;
        _imageCollectionView.hidden = NO;
        _profileTableView.hidden = YES;
        
    } else if (_segment.selectedSegmentIndex == 2) {
        
        dispatch_once(&_setupCVTokenII, ^{
            _profileTableView = [[UITableView alloc]initWithFrame:_tourCollectionView.frame style:UITableViewStylePlain];
            _profileTableView.dataSource = self;
            _profileTableView.delegate = self;
            _profileTableView.scrollEnabled = NO;
            
            [_profileTableView registerNib:[UINib nibWithNibName:@"ProfileVCProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileVCProfileCell"];
            [self.view addSubview:_profileTableView];
        });
        
        _profileTableView.hidden = NO;
        _tourCollectionView.hidden = YES;
        _imageCollectionView.hidden = YES;
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_intro scrollRangeToVisible:NSMakeRange(0, 0)];
    [self setupCollectionViewData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBAction

- (IBAction)segmentValueChanged:(id)sender {
    [self setupCollectionViewData];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSUInteger result = 0;
    if (_segment.selectedSegmentIndex == 0) {
        result = _tourInfoArray.count;
    } else if (_segment.selectedSegmentIndex == 1) {
        result = _imageInfoArray.count;
    }
    return result;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 2;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    return insets;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.view.frame.size.width / 3.15, 4/3*self.view.frame.size.width / 3.15);
//    return CGSizeMake(80, 80);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell;
    
    if (collectionView.tag == 10) {
        ProfileVCTourCell *profileCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileVCTourCell" forIndexPath:indexPath];
        if (profileCell.imageView.image) {
            profileCell.imageView.image = nil;
        }
        Tour *tour = _tourInfoArray[indexPath.row];
        
        [_comm downloadImageWithImageID:tour.tourCoverImageID completion:^(NSError *error, id result) {
            profileCell.imageView.image = result;
            [profileCell.button setTitle:tour.tourName forState:UIControlStateNormal];
        }];
        
        cell = profileCell;
        
    } else if (collectionView.tag == 20) {
        ProfileVCImageCell *profileCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
        if (profileCell.imageView.image) {
            profileCell.imageView.image = nil;
        }
        
        profileCell.imageView = [UIImageView new];
        profileCell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        profileCell.imageView.clipsToBounds = YES;
//        profileCell.imageView.frame = CGRectMake(7, 10, 40, 40);
        profileCell.imageView.frame = CGRectMake(0, 0, profileCell.frame.size.width, profileCell.frame.size.height);
        [profileCell.contentView addSubview:profileCell.imageView];
        
        [_comm downloadImageWithImageID:_imageInfoArray[indexPath.row] completion:^(NSError *error, id result) {
            profileCell.imageView.image = result;

        }];
        
        cell = profileCell;
    }

//    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.bounds.size.width/3, self.view.bounds.size.width/3*4);
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 10) {
        Tour *selectedTour = _tourInfoArray[indexPath.row];
        NSString *tourID = selectedTour.tourID;
        [self performSegueWithIdentifier:@"SegueToTourView" sender:tourID];
    } else if (collectionView.tag == 20) {
        NSString *imageID = _imageInfoArray[indexPath.row];
        [self performSegueWithIdentifier:@"SegueToImageView" sender:imageID];
    }
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return _targetUserInfo.count;
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProfileVCProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileVCProfileCell"];
    
    NSString *titleText;
    NSString *detailText;
    
    switch (indexPath.row) {
        case 0:
            titleText = @"User ID :";
            detailText = _targetUserInfo[@"id"];
            break;
        case 1:
            titleText = @"Name :";
            detailText = _targetUserInfo[@"profile_name"];
            break;
        case 2:
            titleText = @"Sex :";
            detailText = _targetUserInfo[@"sex"];
            break;
        case 3:
            titleText = @"Country :";
            detailText = _targetUserInfo[@"country"];
            break;
        case 4:
            titleText = @"E-mail :";
            detailText = _targetUserInfo[@"email"];
            break;
    }
    
    cell.textLabel.text = titleText;
    cell.detailTextLabel.text = detailText;
    

    cell.detailTextLabel.userInteractionEnabled = YES;
    return cell;
}

#pragma mark TableView Delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    if (tableView.scrollEnabled) {
        return;
    }
    
    tableView.scrollEnabled = tableView.frame.size.height > tableView.contentSize.height + cell.frame.size.height ? NO : YES;
}

#pragma mark - ImagePicker
- (IBAction)editProfileImageBtnPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Image From" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        
    }];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)launchImagePickerWithSourceType:(UIImagePickerControllerSourceType) sourceType {
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]==false) {
        NSLog(@"Invlid Source Type.");
        return;
    }
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *newImage = info[UIImagePickerControllerOriginalImage];
        newImage = [newImage imageScaledToQuarter];
        
        [_comm uploadProfileImageWithImage:newImage userID:_userid completion:^(NSError *error, id result) {
            NSLog(@"result:%@",result);
            _userImage.image = newImage;
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueToTourView"]) {
        TourViewController *vc = [segue destinationViewController];
        vc.targetTourID = sender;
    } else if ([segue.identifier isEqualToString:@"SegueToImageView"]) {
        ImageViewController *vc = [segue destinationViewController];
        vc.targetImageID = sender;
    }
}


@end
