//
//  MessageTableViewCell.h
//  PicTrip
//
//  Created by 張峻綸 on 2016/7/11.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *postUserBtn;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
