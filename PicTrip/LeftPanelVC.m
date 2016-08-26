//
//  LeftPanelVC.m
//  PictureMapPractice
//
//  Created by 塗政勳 on 2016/6/9.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "LeftPanelVC.h"
#import "LeftPanelCell.h"
#import "Function.h"

@interface LeftPanelVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *functionArray;

@end

@implementation LeftPanelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupFunctionArray];
}
-(void)dealloc{
    NSLog(@"LeftPanel dealloc");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupFunctionArray{
    self.functionArray = [NSMutableArray new];
    NSString *userid = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    _functionArray = [NSMutableArray arrayWithArray:@[
    userid?[Function funtionWithFunctionName:@"Logout" DestinationVCIdentifier:@"SegueToLoginViewController"]:[Function funtionWithFunctionName:@"Login" DestinationVCIdentifier:@"SegueToProfileVC"]
    ,[Function funtionWithFunctionName:@"Profile" DestinationVCIdentifier:@"SegueToProfileVC"]
    ,[Function funtionWithFunctionName:@"Map Mode" DestinationVCIdentifier:@"SegueToProfileVC"]
    ,[Function funtionWithFunctionName:@"Page Mode"DestinationVCIdentifier:@"SegueToProfileVC"]
    ,[Function funtionWithFunctionName:@"Begin a New Journey"DestinationVCIdentifier:@"SegueToUpdate_trip"]
    ,[Function funtionWithFunctionName:@"Settings" DestinationVCIdentifier:@"SegueToProfileVC"]
    ]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
//    NSLog(@"%li",(unsigned long)self.functionArray.count);
    return self.functionArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LeftPanelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftPanelCell" forIndexPath:indexPath];
    Function *currentFunction = _functionArray[indexPath.row];
    cell.textLabel.text = currentFunction.functionName;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Function *selectedFunction = _functionArray[indexPath.row];
    [_delegate didSelectedFunctionWithIdentifier:selectedFunction.destinationVCIdentifier];

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
