//
//  TmpViewController.m
//  PicTrip
//
//  Created by 張峻綸 on 2016/6/23.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "TmpViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface TmpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fbPhoto;

@end

@implementation TmpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults * fbUserInfo=[NSUserDefaults standardUserDefaults];
    if (FBSDKAccessToken.currentAccessToken==nil) {
        // User is logged in, do work such as go to next view controller.
        [fbUserInfo setObject:nil forKey:@"result"];
        [fbUserInfo setObject:nil forKey:@"imageData"];
        id result=[fbUserInfo objectForKey:@"result"];
        [_emailLabel setText:result[@"email"]];
        [_nameLabel setText:result[@"name"]];
        
    }else{
        id result=[fbUserInfo objectForKey:@"result"];
        [_emailLabel setText:result[@"email"]];
        [_nameLabel setText:result[@"name"]];
        NSData *imageData=[fbUserInfo objectForKey:@"imageData"];
        self.fbPhoto.image = [UIImage imageWithData:imageData];
    }
    

}

-(void)viewDidAppear:(BOOL)animated{
    NSUserDefaults * fbUserInfo=[NSUserDefaults standardUserDefaults];
    id result=[fbUserInfo objectForKey:@"result"];
    [_emailLabel setText:result[@"email"]];
    [_nameLabel setText:result[@"name"]];
    NSData *imageData=[fbUserInfo objectForKey:@"imageData"];
    self.fbPhoto.image = [UIImage imageWithData:imageData];
}

- (IBAction)logoutBtnPressed:(UIButton *)sender {
    FBSDKAccessToken.currentAccessToken=nil;
    //    [self.navigationController popViewControllerAnimated:true];
    [self dismissViewControllerAnimated:true completion:nil];
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
