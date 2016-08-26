//
//  ImageViewController.m
//  PicTrip
//
//  Created by 張峻綸 on 2016/7/5.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "ImageViewController.h"
#import "LoginViewController.h"
#import "ImageTableViewCell.h"
#import "MessageViewController.h"
#import "PTCommunicator.h"
#import "ProfileVC.h"

#define POST_TOURID @"888"
#define TARGET_TYPE @"image"
@interface ImageViewController ()
{
   
    NSUInteger likeNumber;
    NSMutableArray *messageArray;
    UIButton *cellMessageBtn;
    PTCommunicator *comm;
    NSString *userId;
    NSMutableArray *messageUserImageArray;
    NSMutableArray *messageUserIdArray;
    ImageTableViewCell *cell;
}
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *imageDescription;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UITableView *imageTableView;



@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.

    comm=[PTCommunicator sharedInstance];
    
    userId =[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    cellMessageBtn = [UIButton new];
    cellMessageBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    
    [cellMessageBtn addTarget:self action:@selector(messageBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
   
    
    //DoubleTap 雙擊Like
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeBtnPressed:)];
    
    //設置照片點兩下有作用
    tap.numberOfTapsRequired = 2;
    
    self.postImage.userInteractionEnabled = YES;
    [self.postImage addGestureRecognizer:tap];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"PostImageMessage" object:nil];
    cell = [ImageTableViewCell new];
}
-(void)updateTableView{

    [self reloadMessage];
    
    [self.imageTableView reloadData];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:NO];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [self reloadMessage];
    [self reloadImageUserInfo];
    [self checkLike];
    [self getLikeNumber];

}

-(void)reloadImageUserInfo{
    //得到照片
    [comm downloadImageWithImageID:self.targetImageID completion:^(NSError *error, id result) {
        self.postImage.image=result;
        
    }];
    //得到照片description
    [comm getImageInfoWithImageID:self.targetImageID completion:^(NSError *error, id result) {
        self.imageDescription.text=result[@"imageInfo"][@"description"];
        NSString *userIDInfo = result[@"imageInfo"][@"user_id"];
        [comm getUserInfoWithUserID:userIDInfo completion:^(NSError *error, id result) {
            NSString *profile_image_id = result[@"userInfo"][@"profile_image_id"];
            [comm downloadProfileImageWithImageID:profile_image_id completion:^(NSError *error, id result) {
                self.userImage.clipsToBounds=YES;
                self.userImage.layer.cornerRadius=CGRectGetWidth(self.userImage.frame)/2;
                self.userImage.image = result;
            }];
        }];
    }];

}
-(void)reloadMessage{
    messageArray=[NSMutableArray new];
    messageUserIdArray=[NSMutableArray new];
    messageUserImageArray = [NSMutableArray new];
    [comm getCommentsWithTargetID:self.targetImageID targetType:@"image" completion:^(NSError *error, id result) {
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
            NSString *str = result[@"comments"][i][@"user_id"];
            NSString *str1 = result[@"comments"][i][@"content"];
            
            [comm getUserInfoWithUserID:str completion:^(NSError *error, id result) {

                tmpArray2=@[result[@"userInfo"][@"profile_name"],str1];
                [messageArray replaceObjectAtIndex:i withObject:tmpArray2];
                
                NSString *profileImageArray=result[@"userInfo"][@"profile_image_id"];
                
                [comm downloadProfileImageWithImageID:profileImageArray completion:^(NSError *error, id result) {
                    if (error) {
                        return ;
                    }
                    
                    [messageUserImageArray replaceObjectAtIndex:i withObject:result];
                    
                    count +=1;
                    if (count == tmpArray.count) {
                        [self.imageTableView reloadData];
                    }
                }];
            }];
        }
    }];

}

-(void)checkLike{
    //確認該使用者是否有按過讚
    [comm checkLikeWithUserID:userId targetID:self.targetImageID targetType:TARGET_TYPE completion:^(NSError *error, id result) {
        //        NSLog(@"checkLike:%@",result?result :error);
        
        NSArray * checkLikeArray = [[NSArray alloc]initWithArray:result[@"likes"]];
        
        for (int i=0; i<checkLikeArray.count; i++) {
            if ([checkLikeArray[i][@"user_id"]isEqualToString:userId ]) {
                self.likeBtn.selected=YES;
                self.likeLabel.hidden=NO;
            }
        }
        
    }];

}

-(void)getLikeNumber{
    //得到目前照片的按讚數
    [comm getLikesWithTargetID:self.targetImageID targetType:TARGET_TYPE completion:^(NSError *error, id result) {
        //        NSLog(@"Likenumber:%@",result?result :error);
        
        if (result[@"errorCode"]) {
            likeNumber = 0;
            self.likeLabel.hidden=true;
        }
        if (result[@"likes"]) {
//            {
//                likes =     (
//                             {
//                                 id = 20;
//                                 "image_id" = 70;
//                                 "user_id" = 17;
//                             }
//                             );
//                result = 1;
//            }
            NSArray * likenumber2=[NSArray arrayWithArray:result[@"likes"]];
            //            NSString * numberString=[NSString stringWithFormat:@"%lu",(unsigned long)likenumber2.count];
            likeNumber = likenumber2.count;
            self.likeLabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)likeNumber];
            if (likeNumber > 0) {
                self.likeLabel.hidden=NO;
            }else{
                self.likeLabel.hidden=YES;
            }
            //            NSLog(@"likenumber:%d",likeNumber);
            
        }
    }];

}

#pragma mark - likeBtnPressed
- (IBAction)likeBtnPressed:(UIButton *)sender {
    if (self.likeBtn.selected) {
        self.likeBtn.selected=false;
        
        [comm uploadLikeWithUserID:userId targetID:self.targetImageID targetType:TARGET_TYPE completion:^(NSError *error, id result) {
            if(error){
                NSLog(@"%@",error);
            }
            if (result) {
                likeNumber = likeNumber-1;
                self.likeLabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)likeNumber];
            }
            if (likeNumber==0) {
                self.likeLabel.hidden=true;
            }else{
                self.likeLabel.hidden=false;
            }
        }];
       
        
    }else{
        [comm uploadLikeWithUserID:userId targetID:self.targetImageID targetType:@"image" completion:^(NSError *error, id result) {

            if (result) {
                self.likeBtn.selected=true;
                likeNumber = likeNumber+1;
                self.likeLabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)likeNumber];
            }
            
            if (likeNumber!=0) {
                self.likeLabel.hidden=false;
            }else{
                self.likeLabel.hidden=true;
            }
        }];
        
        
    }
}

#pragma mark - messageBtnPressed


- (IBAction)messageBtnPressed:(UIButton *)sender {
    //準備下一頁

    MessageViewController * second =(MessageViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];

    second.targetImageID=self.targetImageID;
    //顯示下一頁
//    [self.navigationController pushViewController:second animated:true];
    [self showViewController:second sender:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    if (messageArray.count>4) {
        return 4;
    }
    
    return messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
   
    
  
    if (messageArray.count>4) {
        if (indexPath.row == 0) {
            cell.userImage.hidden=YES;
            cell.postUserBtn.hidden=YES;
            cell.postMessageLabel.hidden=YES;
            NSString * messageString=[NSString stringWithFormat:@"查看全部%lu則留言",(unsigned long)messageArray.count];
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
            
                
//                dispatch_async(dispatch_get_main_queue(), ^{
                    //set the position of the button
            cellMessageBtn.tintColor= [UIColor grayColor];
            cellMessageBtn.frame = CGRectMake(0, 0, 180, 30);
            cellMessageBtn.center = cell.center;
            [cellMessageBtn setTitle:messageString forState:UIControlStateNormal];
                    [cell.contentView addSubview:cellMessageBtn];
//                });
            
//            });
//            cellMessageBtn.frame = CGRectMake(0, 0, 250, 30);
//            cellMessageBtn.titleLabel.text=messageString;
            
//            [cellMessageBtn setTitle:messageString forState:UIControlStateNormal];
            
        }else{
            [cell.postUserBtn setTitle:messageArray[indexPath.row-1][0] forState:UIControlStateNormal];
            cell.postUserBtn.tintColor=[UIColor blackColor];
            cell.postUserBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
            cell.postUserBtn.tag=indexPath.row-1;
//            [cell.postUserBtn addTarget:self action:@selector(toUserInfo) forControlEvents:UIControlEventTouchUpInside];
            cell.postMessageLabel.text=messageArray[indexPath.row-1][1];
            cell.userImage.clipsToBounds=YES;
            cell.userImage.layer.cornerRadius=CGRectGetWidth(cell.userImage.frame)/2;
            cell.userImage.clipsToBounds=YES;
            cell.userImage.layer.cornerRadius=CGRectGetWidth(cell.userImage.frame)/2;
            
            
            
            
            cell.userImage.image = messageUserImageArray[indexPath.row];
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return cell;
    }else{
        cell.postUserBtn.tintColor=[UIColor blackColor];
        cell.postUserBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [cell.postUserBtn setTitle:messageArray[indexPath.row][0] forState:UIControlStateNormal];
        cell.postUserBtn.tag=indexPath.row;
        cell.postMessageLabel.text=messageArray[indexPath.row][1];
    }
    
    // Configure the cell...
    cell.userImage.clipsToBounds=YES;
    cell.userImage.layer.cornerRadius=CGRectGetWidth(cell.userImage.frame)/2;
    cell.userImage.image = messageUserImageArray[indexPath.row];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

//製作逃生門

-(IBAction)backToImageViewController:(UIStoryboardSegue*)sender {
    
}

- (IBAction)goToProfile:(UIButton *)sender {

    
    UIStoryboard *Main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileVC * second =(ProfileVC*)[Main instantiateViewControllerWithIdentifier:@"ProfileVC"];
    second.targetUserID =messageUserIdArray[sender.tag];
    [self.navigationController pushViewController:second animated:true];
}

//-(void)toMessage{
//    NSLog(@"To Message");
//}
//-(void)toUserInfo{
//    NSLog(@"To User Info");
//}





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
