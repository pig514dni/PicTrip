//
//  LeftPanelVC.h
//  PictureMapPractice
//
//  Created by 塗政勳 on 2016/6/9.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LeftPanelVCDelegate <NSObject>

@required
-(void)didSelectedFunctionWithIdentifier:(NSString*)destinationVCIdentifier;

@end

@interface LeftPanelVC : UIViewController
@property (nonatomic)id<LeftPanelVCDelegate> delegate;
@end
