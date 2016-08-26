//
//  MessageViewController.m
//  PicTrip
//
//  Created by 張峻綸 on 2016/7/13.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageTableViewCell.h"
#import "PTCommunicator.h"
#import "ProfileVC.h"

@interface MessageViewController ()<UITextFieldDelegate>
{
     PTCommunicator *comm;
    NSString * userId;
    NSMutableArray *messageUserImageArray;
    NSMutableArray *messageUserIdArray;
    MessageTableViewCell *cell;
}
@property (weak, nonatomic) IBOutlet UITextField *inputMessageTextField;
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (weak, nonatomic) IBOutlet UIView *messageView;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView:) name:@"PostMessage" object:nil];
    comm = [PTCommunicator sharedInstance];
    
    userId= [[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.inputMessageTextField.returnKeyType=UIReturnKeySend;//更改返回键的文字 (或者在sroryBoard中的,选中UITextField,对return key更改)
    self.inputMessageTextField.delegate=self;
    [self reloadMessage];
    userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    cell=[MessageTableViewCell new];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
//-(void)updateTableView:(NSNotification*)notify{
//    
//    NSArray *array=notify.object;
//    [self.messageArray addObject:array];
//    
//    [self.messageTableView reloadData];
//    
//}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    return self.messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
     cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
   
    cell.userImage.clipsToBounds=YES;
    cell.userImage.layer.cornerRadius=CGRectGetWidth(cell.userImage.frame)/2;
    cell.userImage.image = messageUserImageArray[indexPath.row];
    

    [cell.postUserBtn setTitle:self.messageArray[indexPath.row][0] forState:UIControlStateNormal];
    cell.postUserBtn.tintColor=[UIColor blackColor];
    cell.postUserBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    cell.postUserBtn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    cell.postUserBtn.tag=indexPath.row;
    cell.messageLabel.text=self.messageArray[indexPath.row][1];
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
    NSLog(@"inputMessage");
    
    NSDictionary *contentDic= [comm generateCommentInfoWithUserID:userId targetID:self.targetImageID content:self.inputMessageTextField.text targetType:@"image"];
    
    [comm uploadCommentWithCommentInfo:contentDic completion:^(NSError *error, id result) {
        if (error) {
            NSLog(@"upload Content Error : %@",error);
        }
        else{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"PostImageMessage" object:nil];
            NSLog(@"upload Content Sussec : %@",result);
            self.inputMessageTextField.text=@"";
            [self reloadMessage];
        }
    }];
    //    NSArray *tmpMessageArray=@[@"inputUser",self.inputMessageTextField.text];
    //            self.inputMessageTextField.text=@"";
    //    [[NSNotificationCenter defaultCenter]postNotificationName:@"PostMessage" object:tmpMessageArray];
    //    [self.messageArray addObject:tmpMessageArray];
    //    [self.messageTableView reloadData];
}

-(void)reloadMessage{
    self.messageArray=[NSMutableArray new];
    messageUserImageArray=[NSMutableArray new];
    messageUserIdArray=[NSMutableArray new];
    [comm getCommentsWithTargetID:self.targetImageID targetType:@"image" completion:^(NSError *error, id result) {
        if (error) {
            NSLog(@"reloadMessage :Error");
            return ;
        }
        NSLog(@"getContent : %@",result);
        NSArray *tmpArray=[NSArray arrayWithArray:result[@"comments"]];
        for (int i=0; i<tmpArray.count; i++) {
            [self.messageArray addObject:tmpArray];
            [messageUserImageArray addObject:tmpArray];
        }
        __block NSArray * tmpArray2;
        __block int count=0;
        for (int i=0; i<tmpArray.count; i++) {
            [messageUserIdArray addObject:result[@"comments"][i][@"user_id"]];
            NSString *str = result[@"comments"][i][@"user_id"];
            NSString *str1 = result[@"comments"][i][@"content"];
            
            [comm getUserInfoWithUserID:str completion:^(NSError *error, id result) {
                
                NSLog(@"id for name :%@",result[@"userInfo"][@"profile_name"]);
                tmpArray2 =@[result[@"userInfo"][@"profile_name"],str1];
                [self.messageArray replaceObjectAtIndex:i withObject:tmpArray2];
                
                //                [self.messageArray insertObject:tmpArray3 atIndex:i];
                //                [self.messageArray initWithArray:tmpArray2];
                
                
                
                
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
//                count +=1;
//                if (count == tmpArray.count) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [self.messageTableView reloadData];
//                    });
//                }
                
            }];
        }
        
    }];
    //    [self.messageTableView reloadData];
}

- (IBAction)goToProfile:(UIButton *)sender {
     NSLog(@"goToProfileId:%@",messageUserIdArray[sender.tag]);
    UIStoryboard *Main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileVC * second =(ProfileVC*)[Main instantiateViewControllerWithIdentifier:@"ProfileVC"];
    second.targetUserID =messageUserIdArray[sender.tag];
    [self.navigationController pushViewController:second animated:true];
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

}
#pragma mark 滚动TableView去除键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.inputMessageTextField resignFirstResponder];
}
//
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
