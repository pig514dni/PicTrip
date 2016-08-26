//
//  TourViewController.m
//  PicTrip
//
//  Created by 張峻綸 on 2016/7/20.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "TourViewController.h"
#import "TourTableViewCell.h"
#import "TourCollectionViewCell.h"
#import "TourMessageViewController.h"
#import "PTCommunicator.h"
#import "ImageViewController.h"
#import "ProfileVC.h"
#define TARGET_TYPE @"tour"
@interface TourViewController (){
    PTCommunicator * comm;
    UIButton *cellMessageBtn; //當留言數大於4則時,產生此button
    NSMutableArray * messageArray; //儲存總留言數
    NSUInteger likeNumber; //儲存目前按讚數
    NSMutableArray  *imageArray; //儲存此Tour的全部照片
    
    NSMutableArray *imageIdArray; //儲存此Tour的全部照片Id
    NSString * userId;
    NSString * TourUserId;
    NSMutableArray *messageUserImageArray;
    NSMutableArray *messageUserIdArray;
    TourTableViewCell *cell;
    int btnInt;
}

//此Tour的留言TableView
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

//此Tour的照片CollectionView
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;

//此Tour的目前按讚數
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;

//此Tour的按讚按鈕
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

//觀看此Tour的全部留言內容
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *TourUserImage;
@property (weak, nonatomic) IBOutlet UILabel *TourDescription;

@property (nonatomic) dispatch_once_t onceToken;
@end

@implementation TourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    comm = [PTCommunicator sharedInstance];
    self.onceToken = 0;
    btnInt=0;
    userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    
    
    
    //設置CollectionView底色為白色,預設為黑色
    self.imageCollectionView.backgroundColor=[UIColor whiteColor];
    
    //
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTableView) name:@"PostTourMessage"  object:nil];
    //
    //    //下載此Tour的照片 留言
    //    [self reloadMessage];
    //    [self reloadImage];
    //    [self checkLike];
    //    [self getLikeNumber];
    //    [self downLoadTourUserInfo];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
    
}

-(void)updateTableView{
    
    [self reloadMessage];
    //    [self.messageTableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //將NavigationBar隱藏,如要顯示需改為false
    [self.navigationController setNavigationBarHidden:false animated:false];
    [self reloadMessage];
    [self reloadImage];
    [self checkLike];
    [self getLikeNumber];
    [self downLoadTourUserInfo];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //如果留言數大於4則,只顯示4則
    if (messageArray.count>4) {
        return 4;
    }
    
    return messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (messageArray.count>4) {
        
        //如果留言數大於4則,則創立一個Button讓User可以跳去下一頁觀看全部留言
        if (indexPath.row == 0) {
            
            //把其他的物件隱藏,只顯示Button
            cell.userImage.hidden=YES;
            cell.postUserBtn.hidden=YES;
            cell.postMessageLabel.hidden=YES;
            
            NSString * messageString=[NSString stringWithFormat:@"查看全部%lu則留言",(unsigned long)messageArray.count];
            
            if (cellMessageBtn) {
                [cellMessageBtn removeFromSuperview];
                cellMessageBtn = nil;
            }
            
            cellMessageBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            cellMessageBtn.frame = CGRectMake(0, 0, 180, 30);
            cellMessageBtn.center = cell.center;
            
            [cellMessageBtn addTarget:self action:@selector(messageBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            //            cellMessageBtn.hidden=false;
            cellMessageBtn.tintColor= [UIColor grayColor];
            [cellMessageBtn setTitle:messageString forState:UIControlStateNormal];
            
            //            if (btnInt == 0) {
            [cell.contentView addSubview:cellMessageBtn];
            
            
        }else{
            
            //設定使用者名稱的Button名字 顏色 粗體
            [cell.postUserBtn setTitle:messageArray[indexPath.row-1][0] forState:UIControlStateNormal];
            cell.postUserBtn.tintColor=[UIColor blackColor];
            cell.postUserBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
            cell.postUserBtn.tag=indexPath.row-1;
            
            //秀出留言者留言內容
            cell.postMessageLabel.text=messageArray[indexPath.row-1][1];
            cell.userImage.clipsToBounds=YES;
            cell.userImage.layer.cornerRadius=CGRectGetWidth(cell.userImage.frame)/2;
            cell.userImage.image = messageUserImageArray[indexPath.row-1];
            
        }
        
        //把每個Cell間的線取消
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return cell;
    }else{
        //設定使用者名稱的Button名字 顏色 粗體
        cell.postUserBtn.tintColor=[UIColor blackColor];
        cell.postUserBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [cell.postUserBtn setTitle:messageArray[indexPath.row][0] forState:UIControlStateNormal];
        
        //        cell.postUserBtn.tag=1;
        //秀出留言者留言內容
        //        if (indexPath.row == nil) {
        //
        //        }
        cell.postUserBtn.tag=indexPath.row;
        cell.postMessageLabel.text=messageArray[indexPath.row][1];
        
        cell.userImage.clipsToBounds=YES;
        cell.userImage.layer.cornerRadius=CGRectGetWidth(cell.userImage.frame)/2;
        cell.userImage.image = messageUserImageArray[indexPath.row];
        
        //記錄留言者ID
        
        //把每個Cell間的線取消
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        
        return cell;
    }
    
    
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    NSLog(@"didSelectRowAtIndexPath:%ld",(long)indexPath.row);
//}

//設置tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    // NSLog(@"%lu",(unsigned long)noLocation.count);
    return imageArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TourCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    collectionViewCell.tourImage.image=imageArray[indexPath.row];
    
    
    return collectionViewCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    ImageViewController * second =(ImageViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    
    second.targetImageID = imageIdArray[indexPath.row];
    [self showViewController:second sender:nil];
    
}

-(void)downLoadTourUserInfo{
    
    
    [comm getTourInfoWithTourID:self.targetTourID completion:^(NSError *error, id result) {
        if (error) {
            return ;
        }
        
        TourUserId = result[@"tourInfo"][@"user_id"];
        self.TourDescription.text= result[@"tourInfo"][@"description"];
        [comm getUserInfoWithUserID:TourUserId completion:^(NSError *error, id result) {
            NSLog(@"%@",result);
            NSString *TourUserId2 = result[@"userInfo"][@"profile_image_id"];
            
            [comm downloadProfileImageWithImageID:TourUserId2 completion:^(NSError *error, id result) {
                if (error) {
                    return ;
                }
                self.TourUserImage.clipsToBounds=YES;
                self.TourUserImage.layer.cornerRadius=CGRectGetWidth(self.TourUserImage.frame)/2;
                self.TourUserImage.image=result;
                
            }];
        }];
        
    }];
    
    
}

#pragma mark reloadMessage
-(void)reloadMessage{
    //    cellMessageBtn = [UIButton new];
    messageArray=[NSMutableArray new];
    messageUserImageArray = [NSMutableArray new];
    messageUserIdArray = [NSMutableArray new];
    [comm getCommentsWithTargetID:self.targetTourID targetType:TARGET_TYPE completion:^(NSError *error, id result) {
        //        NSLog(@"getContent : %@",result);
        NSArray *tmpArray=[NSArray arrayWithArray:result[@"comments"]];
        for (int i=0; i<tmpArray.count; i++) {
            [messageArray addObject:tmpArray];
            [messageUserImageArray addObject:tmpArray];
        }
        
        __block NSArray *tmpArray2;
        __block int count=0;
        
        for (int i=0; i<tmpArray.count; i++) {
            
            [messageUserIdArray addObject:result[@"comments"][i][@"user_id"]];
            NSString *str =result[@"comments"][i][@"user_id"];
            NSString *str1 = result[@"comments"][i][@"content"];
            
            [comm getUserInfoWithUserID:str completion:^(NSError *error, id result) {
                //                NSLog(@"id for name :%@",result[@"userInfo"][@"profile_name"]);
                
                
                tmpArray2=@[result[@"userInfo"][@"profile_name"],str1];
                [messageArray replaceObjectAtIndex:i withObject:tmpArray2];
                
                NSString *profileImageArray=result[@"userInfo"][@"profile_image_id"];
                
                [comm downloadProfileImageWithImageID:profileImageArray completion:^(NSError *error, id result) {
                    if (error) {
                        return ;
                    }
                    
                    //                    [messageUserImageArray addObject:result];
                    [messageUserImageArray replaceObjectAtIndex:i withObject:result];
                    
                    count +=1;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (count == tmpArray.count) {
                            [self.messageTableView reloadData];
                        }
                    });
                    
                }];
                
            }];
        }
    }];
    
}

-(void)reloadImage{
    //下載照片
    imageIdArray  = [NSMutableArray new];
    imageArray = [NSMutableArray new];
    [comm getTourInfoWithTourID:self.targetTourID completion:^(NSError *error, id result) {
        NSLog(@"TOUR: %@",result);
        NSString * imagesId=result[@"tourInfo"][@"images_id"];
        NSArray * imagesIdArray= [imagesId componentsSeparatedByString:@","];
        
        for (int i=0; i<imagesIdArray.count-1; i++) {
            [imageArray addObject:@""];
            [imageIdArray addObject:@""];
        }
        __block int count2 =0;
        for (int i=0; i<imagesIdArray.count-1; i++) {
            [comm downloadImageWithImageID:imagesIdArray[i] completion:^(NSError *error, id result) {
                NSLog(@"down:%@",result);
                [imageIdArray replaceObjectAtIndex:i withObject:imagesIdArray[i]];
                [imageArray replaceObjectAtIndex:i withObject:result];
                count2 +=1;
                if (count2 == imagesIdArray.count-1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.imageCollectionView  reloadData];
                        
                    });
                }
            }];
        }
    }];
}

-(void)checkLike{
    //確認該使用者是否有按過讚
    [comm checkLikeWithUserID:userId targetID:self.targetTourID targetType:TARGET_TYPE completion:^(NSError *error, id result) {
        
        if (result) {
            NSArray * checkLikeArray = [[NSArray alloc]initWithArray:result[@"likes"]];
            
            for (int i=0; i<checkLikeArray.count; i++) {
                
                if ([checkLikeArray[i][@"user_id"]isEqualToString:userId ]) {
                    self.likeBtn.selected=YES;
                    self.likeLabel.hidden=NO;
                }
                
            }
        }
        
    }];
}

-(void)getLikeNumber{
    //得到目前Tour的按讚數
    [comm getLikesWithTargetID:self.targetTourID targetType:TARGET_TYPE completion:^(NSError *error, id result) {
        if (result[@"errorCode"]) {
            likeNumber = 0;
            self.likeLabel.hidden=true;
        }
        if (result[@"result"]) {
            NSArray * likenumber2=[NSArray arrayWithArray:result[@"likes"]];
            
            likeNumber = likenumber2.count;
            
            if (likeNumber > 0) {
                self.likeLabel.hidden=false;
            }else{
                self.likeLabel.hidden=true;
            }
            
            self.likeLabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)likeNumber];
        }
        
    }];
    
}

- (IBAction)likeBtnPressed:(UIButton *)sender {
    
    if (self.likeBtn.selected) {
        self.likeBtn.selected=NO;
        
        [comm uploadLikeWithUserID:userId targetID:self.targetTourID targetType:TARGET_TYPE completion:^(NSError *error, id result) {
            
            if (result) {
                likeNumber = likeNumber-1;
                self.likeLabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)likeNumber];
            }
            if (likeNumber==0) {
                self.likeLabel.hidden=YES;
            }
        }];
        
        
    }else{
        [comm uploadLikeWithUserID:userId targetID:self.targetTourID  targetType:TARGET_TYPE completion:^(NSError *error, id result) {
            
            if (result) {
                self.likeBtn.selected=YES;
                likeNumber = likeNumber+1;
                self.likeLabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)likeNumber];
            }
            if (likeNumber!=0) {
                self.likeLabel.hidden=NO;
            }
        }];
    }
}
- (IBAction)messageBtnPressed:(UIButton *)sender {
    //準備下一頁
    //    MessageTableViewController * second =(MessageTableViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MessageTableViewController"];
    //    second.messageArray=[[NSMutableArray alloc]initWithArray:messageArray];
    TourMessageViewController * second =(TourMessageViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"TourMessageViewController"];
    //    second.messageArray=[[NSMutableArray alloc]initWithArray:messageArray];
    //    MessageViewController
    second.targetTourID=self.targetTourID;
    //顯示下一頁
    [self showViewController:second sender:nil];
    
}


- (IBAction)goToProfileId:(UIButton *)sender {
    
    NSLog(@"goToProfileId:%@",messageUserIdArray[sender.tag]);
    UIStoryboard *Main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileVC * second =(ProfileVC*)[Main instantiateViewControllerWithIdentifier:@"ProfileVC"];
    second.targetUserID =messageUserIdArray[sender.tag];
    [self.navigationController pushViewController:second animated:true];
    
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

@end
