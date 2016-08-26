//
//  RegisrerViewController.m
//  PicTrip
//
//  Created by 張峻綸 on 2016/6/23.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "RegisrerViewController.h"
#import "RegisteredTableViewCell.h"
#import "PTCommunicator.h"
@interface RegisrerViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *sexTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *questiionTextField;
@property (weak, nonatomic) IBOutlet UITextField *anserTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *registerPickerView;
@property (strong,nonatomic) NSMutableArray  * tableViewArray;
@property (nonatomic,strong) PTCommunicator *comm;

@end

@implementation RegisrerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _comm = [PTCommunicator sharedInstance];
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.nameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.questiionTextField.delegate = self;
    self.anserTextField.delegate =self;
    
    self.registerPickerView.hidden=true;

}

-(void)dealloc{
    NSLog(@"RegisterViewController dealloc");
}
- (IBAction)cancalRegister:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.tableViewArray.count;
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.tableViewArray[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

    if ([self.tableViewArray[0]isEqualToString:@"台灣"]) {
        
        self.countryTextField.text=self.tableViewArray[row];
    }else{
        self.sexTextField.text=self.tableViewArray[row];
    }
    if(!self.registerPickerView.hidden){
        self.registerPickerView.hidden=true;
    }
}


- (IBAction)sexBtnpressed:(UIButton *)sender {
    [self keyboardResignFirstResponder];
    NSArray * tmpArray=@[@"男",@"女"];
    self.tableViewArray=[[NSMutableArray alloc]initWithArray:tmpArray];
    if(self.registerPickerView.hidden){
        self.registerPickerView.hidden=false;
    }
    
    [self.registerPickerView reloadAllComponents];
}
- (IBAction)countryBtnPressed:(UIButton *)sender {
    
    [self keyboardResignFirstResponder];
    NSArray * tmpArray=@[@"台灣",@"美國",@"日本",@"韓國",@"菲律賓",@"泰國"];
    self.tableViewArray=[[NSMutableArray alloc]initWithArray:tmpArray];
    if(self.registerPickerView.hidden){
        self.registerPickerView.hidden=false;
    }
    NSLog(@"country");
    [self.registerPickerView reloadAllComponents];
}
- (IBAction)registerBtnPressed:(UIButton *)sender {
    NSLog(@"username:%@",self.usernameTextField.text);
    NSLog(@"password:%@",self.passwordTextField.text);
    NSLog(@"email:%@",self.emailTextField.text);
    NSLog(@"sex:%@",self.sexTextField.text);
    NSLog(@"country:%@",self.countryTextField.text);
    NSLog(@"question:%@",self.questiionTextField.text);
    NSLog(@"answer:%@",self.anserTextField.text);
    if ([self.usernameTextField.text isEqual:@""]) {
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"註冊提醒" message:@"UserName欄位不可空白" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok =[UIAlertAction actionWithTitle:@"了解" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
    } else if ([self.passwordTextField.text isEqualToString:@""]){
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"註冊提醒" message:@"Password欄位不可空白" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok =[UIAlertAction actionWithTitle:@"了解" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
    } else {
        NSDictionary *userInfo = [_comm generateUserInfoWithUsername:_usernameTextField.text password:_passwordTextField.text name:_nameTextField.text email:_emailTextField.text sex:_sexTextField.text country:_countryTextField.text question:_questiionTextField.text answer:_anserTextField.text];
        
        [_comm registerWithUserInfo:userInfo completion:^(NSError *error, id result) {
            if ([result[@"result"]boolValue]) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:result[@"user_id"] forKey:@"user_id"];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"error: %@",error? error:result);
            }
            
        }];
    }
    
    
}

-(void) keyboardResignFirstResponder{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self.questiionTextField resignFirstResponder];
    [self.anserTextField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self keyboardResignFirstResponder];

    return true;
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
