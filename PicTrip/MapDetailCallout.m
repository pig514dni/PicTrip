//
//  MapLeftCallout.m
//  PicTrip
//
//  Created by 塗政勳 on 2016/7/20.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "MapDetailCallout.h"
#import "ProfileVC.h"
#import "TourViewController.h"
@interface MapDetailCallout ()

@end

@implementation MapDetailCallout

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)viewProfileBtnPressed:(id)sender {
//    NSString *userID = self.imageInfo[@"user_id"];
//    ProfileVC *vc = [ProfileVC new];
//    vc.targetUserID = userID;
    NSString *targetID = _imageInfo[@"user_id"];
    [_vc performSegueWithIdentifier:@"SegueToProfileVC" sender:targetID];
    NSLog(@"tapped");
}

- (IBAction)viewTourBtnPressed:(id)sender {
    NSString *targetID = _imageInfo[@"tour_id"];
    [_vc performSegueWithIdentifier:@"SegueToTourView" sender:targetID];
    NSLog(@"tapped");

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueToProfileVC"]) {
        ProfileVC *vc = (ProfileVC*)[segue destinationViewController];
        vc.targetUserID = _imageInfo[@"user_id"];
    } else if ([segue.identifier isEqualToString:@"SegueToTourView"]) {
        TourViewController *vc = [segue destinationViewController];
        vc.targetTourID = _imageInfo[@"tour_id"];
    }
    
}


@end
