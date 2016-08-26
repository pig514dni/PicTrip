//
//  LoginViewController.m
//  PicTrip
//
//  Created by 張峻綸 on 2016/6/23.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "RegisrerViewController.h"
#import "InitViewController.h"
#import "PTCommunicator.h"

@interface LoginViewController ()<FBSDKLoginButtonDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *logoLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtnPressed;
@property (weak, nonatomic) IBOutlet UIButton *registerBtnPressed;
@property (weak, nonatomic) IBOutlet UIButton *guestBtnPressed;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton * fbLogin;

@property (nonatomic)BOOL onLogin;
@property (strong,nonatomic)PTCommunicator *comm;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _comm = [PTCommunicator sharedInstance];
    _onLogin = NO;
    
    [FBSDKLoginButton new];
    self.fbLogin.delegate=self;
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.fbLogin.readPermissions=@[@"public_profile", @"email", @"user_friends"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefault objectForKey:@"user_id"];
    
    if (FBSDKAccessToken.currentAccessToken || userid) {
        [self FBSuccessToHidden:true];
    }
    
}

-(void)dealloc{
    NSLog(@"LoginVC dealloc.");
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkLoginStatus];
}
- (IBAction)guestLogin:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"guest" forKey:@"user_id"];
    [self checkLoginStatus];
}

-(void)checkLoginStatus{
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefault objectForKey:@"user_id"];
    
    if (userid) {
        _onLogin = NO;
        [self FBSuccessToHidden:true];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (_onLogin == YES && FBSDKAccessToken.currentAccessToken == nil) {
            _onLogin = NO;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Not Successful" message:@"Please Try Again" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Got It" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error
{
    _onLogin = YES;
    if (result.isCancelled==YES) {
        NSLog(@"User login canceled.");
        return;
    }else{
        if ([result.grantedPermissions containsObject:@"email"]) {
            if ([FBSDKAccessToken currentAccessToken]) {
                NSDictionary *param = @{@"fields" : @"email,id,name,picture.width(300).height(300)"};
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:param] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error && result!=nil) {
                        if([result isKindOfClass:[NSDictionary class]])
                        {
                            NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                            
                            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageStringOfLoginUser]];
                            
                            NSDictionary *fbInfo = result;
                            [_comm getUserIDWithFBID:fbInfo[@"id"] completion:^(NSError *error, id result) {
                                
                                if ([result[@"result"]boolValue]) {
                                    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
                                    [userDefault setObject:result[@"user_id"] forKey:@"user_id"];
                                    [userDefault synchronize];
                                    [self checkLoginStatus];
                                    //                                    [self checkLoginStatus];
                                } else {
                                    NSDictionary* fbUserInfo = [_comm generateFbUserInfoWithFbID:fbInfo[@"id"] email:fbInfo[@"email"] profileName:fbInfo[@"name"]];
                                    [_comm registerWithFbUserInfo:fbUserInfo profileImage:imageData completion:^(NSError *error, id result) {
                                        NSLog(@"register: %@",result? result:error);
                                        NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
                                        [userDefault setObject:result[@"user_id"] forKey:@"user_id"];
                                        [userDefault synchronize];
                                        //                                        [self checkLoginStatus];
                                    }];
                                }
                            }];
                        }
                    }
                }];
            }
        } else {
            NSLog(@"Not granted");
        }
    }
    if(error != nil){
        NSLog(@"error=%@",error);
        return;
    }
    
}
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
    NSUserDefaults * fbUserInfo=[NSUserDefaults standardUserDefaults];
    [fbUserInfo setObject:nil forKey:@"user_id"];
}
- (IBAction)LoginBtnPressed:(UIButton *)sender {
    _onLogin = YES;
    [_comm loginWithUsername:_usernameTextField.text password:_passwordTextField.text completion:^(NSError *error, id result) {
        if (result[@"user_id"]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:result[@"user_id"] forKey:@"user_id"];
            
        }
        [self checkLoginStatus];
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)registerBtnPressed:(UIButton *)sender {
    //準備下一頁
    
    RegisrerViewController * registered =(RegisrerViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"RegisrerViewController"];
    //顯示下一頁
    
    [self presentViewController:registered animated:YES completion:nil];
}
-(void)FBSuccessToHidden:(bool)result{
    self.logoLabel.hidden=result;
    self.usernameTextField.hidden=result;
    self.passwordTextField.hidden=result;
    self.registerBtnPressed.hidden=result;
    self.loginBtnPressed.hidden=result;
    self.fbLogin.hidden=result;
    self.guestBtnPressed.hidden=result;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    return true;
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
