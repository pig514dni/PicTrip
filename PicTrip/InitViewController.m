//
//  InitViewController.m
//  PicTrip
//
//  Created by 張峻綸 on 2016/6/25.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "InitViewController.h"
#import "PTCommunicator.h"
@interface InitViewController ()
@property (nonatomic,strong)PTCommunicator *comm;

@end

@implementation InitViewController
-(void)viewDidLoad{
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefault objectForKey:@"user_id"];
    if (userid ==nil) {
        
        //準備下一頁
        UIViewController * notLogin =[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        //    //顯示下一頁
        [self presentViewController:notLogin animated:true completion:nil];
    }else{
        [self performSegueWithIdentifier:@"GoToMainVC" sender:nil];

    }
}
-(void)dealloc{
    NSLog(@"initView dealloc.");
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
