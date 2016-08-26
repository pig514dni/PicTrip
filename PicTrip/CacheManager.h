//
//  CacheManager.h
//  PicTrip
//
//  Created by 塗政勳 on 2016/7/28.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CacheManager : NSObject

//+(instancetype)sharedInstance;

+(void)savePhotoWithFileName:(NSString *)fileName data:(NSData *)data;
+(UIImage*)loadPhotoWithFileName: (NSString*) fileName;

@end
