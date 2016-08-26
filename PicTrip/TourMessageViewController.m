//
//  TourMessageViewController.m
//  PicTrip
//
//  Created by 張峻綸 on 2016/7/23.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "TourMessageViewController.h"
#import "PTCommunicator.h"
#import "TourMessageTableViewCell.h"
#import "ProfileVC.h"
#define TARGET_TYPE @"tour"
@interface TourMessageViewController ()<UITextFieldDelegate>
{
    PTCommunicator *comm;
    NSMutableArray *messageArray;
    NSString * userId;
    NSMutableArray *messageUserImageArray;
    TourMessageTableViewCell *cell;
    NSMutableArray *messageUserIdArray;
}
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (weak, nonatomic) IBOutlet UITextField *inputMessageTextField;
@property (weak, nonatomic) IBOutlet UIView *messageView;

@end

@implementation TourMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    comm = [PTCommunicator sharedInstance];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.inputMessageTextField.returnKeyType=UIReturnKeySend;//更改返回键的文字 (或者在sroryBoard中的,选中UITextField,对return key更改)
    self.inputMessageTextField.delegate=self;
    [self reloadMessage];
    
    userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    return messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.userImage.clipsToBounds=YES;
    cell.userImage.layer.cornerRadius=CGRectGetWidth(cell.userImage.frame)/2;
    cell.userImage.image = messageUserImageArray[indexPath.row];
    [cell.postUserBtn setTitle:messageArray[indexPath.row][0] forState:UIControlStateNormal];
    //    [cell.postUserBtn setTitle:@"1" forState:UIControlStateNormal];
    cell.postUserBtn.tintColor=[UIColor blackColor];
    cell.postUserBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    cell.postUserBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    cell.postUserBtn.tag=indexPath.row;
    
    //    cell.messageLabel.text=@"3";
    cell.messageLabel.text=messageArray[indexPath.row][1];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}


- (IBAction)inputBtnPressed:(UIButton *)sender {
    
    if ([self.inputMessageTextField.text isEqualToString:@""]) {
        return;
    }
    
    NSDictionary *contentDic= [comm generateCommentInfoWithUserID:userId targetID:self.targetTourID content:self.inputMessageTextField.text targetType:TARGET_TYPE];
    
    [comm uploadCommentWithCommentInfo:contentDic completion:^(NSError *error, id result) {
        if (error) {
            NSLog(@"upload Content Error : %@",error);
        }
        else{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"PostTourMessage"  object:nil];
            NSLog(@"upload Content Sussec : %@",result);
            self.inputMessageTextField.text=@"";
            [self reloadMessage];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark reloadMessage
-(void)reloadMessage{
    messageArray=[NSMutableArray new];
    messageUserImageArray = [NSMutableArray new];
    messageUserIdArray = [NSMutableArray new];
    [comm getCommentsWithTargetID:self.targetTourID  targetType:TARGET_TYPE completion:^(NSError *error, id result) {
        //        NSLog(@"getContent : %@",result);
        if (error) {
            NSLog(@"getComment:Error");
            return ;
        }else{
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
                    //                NSLog(@"id for name :%@",result[@"userInfo"][@"profile_name"]);
                    
                    
                    tmpArray2=@[result[@"userInfo"][@"profile_name"],str1];
                    [messageArray replaceObjectAtIndex:i withObject:tmpArray2];
                    //                    count +=1;
                    //                    if (count == tmpArray.count) {
                    //                        [self.messageTableView reloadData];
                    //                    }
                    NSString *profileImageArray=result[@"userInfo"][@"profile_image_id"];
                    
                    [comm downloadProfileImageWithImageID:profileImageArray completion:^(NSError *error, id result) {
                        if (error) {
                            return ;
                        }
                        
                        [messageUserImageArray replaceObjectAtIndex:i withObject:result];
                        
                        count +=1;
                        if (count == tmpArray.count) {
                            [self.messageTableView reloadData];
                        }
                    }];
                    
                    
                }];
            }
            
        }
        
        //        NSLog(@"messageArray:%@",messageArray);
        
    }];
    
}






#pragma mark TextField的Delegate send后的操作

- (BOOL)textFieldShouldReturn:(UITextField *)textField{  //
    //    NSLog(@"1111111222");
    [self inputBtnPressed:nil]; //发送信息
    
    return YES;
}

#pragma mark 键盘将要出现
-(void)keyboardWillShow:(NSNotification *)notifa{
    [self dealKeyboardFrame:notifa];
}
#pragma mark 键盘消失完毕
-(void)keyboardWillHide:(NSNotification *)notifa{
    [self dealKeyboardFrame:notifa];
}
#pragma mark 处理键盘的位置
-(void)dealKeyboardFrame:(NSNotification *)changeMess{
    NSDictionary *dicMess=changeMess.userInfo;//键盘改变的所有信息
    CGFloat changeTime=[dicMess[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];//通过userInfo 这个字典得到对得到相应的信息//0.25秒后消失键盘
    CGFloat keyboardMoveY=[dicMess[UIKeyboardFrameEndUserInfoKey]CGRectValue].origin.y-[UIScreen mainScreen].bounds.size.height;//键盘Y值的改变(字典里面的键UIKeyboardFrameEndUserInfoKey对应的值-屏幕自己的高度)
    [UIView animateWithDuration:changeTime animations:^{ //0.25秒之后改变tableView和bgView的Y轴
        self.messageTableView.transform=CGAffineTransformMakeTranslation(0, keyboardMoveY);
        self.messageView.transform=CGAffineTransformMakeTranslation(0, keyboardMoveY);
        
    }];
    //    NSIndexPath *path=[NSIndexPath indexPathForItem:self.messageArray.count-1 inSection:0];
    //    [self.messageTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionNone animated:YES];//将tableView的行滚到最下面的一行
}

- (IBAction)goToProfile:(UIButton *)sender {
    NSLog(@"goToProfileId:%@",messageUserIdArray[sender.tag]);
    UIStoryboard *Main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileVC * second =(ProfileVC*)[Main instantiateViewControllerWithIdentifier:@"ProfileVC"];
    second.targetUserID =messageUserIdArray[sender.tag];
    [self.navigationController pushViewController:second animated:true];
}

#pragma mark 滚动TableView去除键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.inputMessageTextField resignFirstResponder];
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
