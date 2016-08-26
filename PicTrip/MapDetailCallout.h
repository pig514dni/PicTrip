//
//  MapLeftCallout.h
//  PicTrip
//
//  Created by 塗政勳 on 2016/7/20.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MapDetailCallout : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imageInfoLabel;
@property (nonatomic,strong) NSDictionary *imageInfo;
@property (weak, nonatomic) IBOutlet UIButton *viewProfileBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewTourBtn;
@property (strong,nonatomic) UIViewController *vc;

@end
