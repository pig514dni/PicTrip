//
//  ImageScale.h
//  PicTrip
//
//  Created by Joe Chen on 2016/7/21.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (scale)


- (UIImage *)imageScaledToQuarter;
- (UIImage *)imageScaledToHalf;
- (UIImage *)imageScaledToScale:(CGFloat)scale;
- (UIImage *)imageScaledToScale:(CGFloat)scale
       withInterpolationQuality:(CGInterpolationQuality)quality;

@end
