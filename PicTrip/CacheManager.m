//
//  CacheManager.m
//  PicTrip
//
//  Created by 塗政勳 on 2016/7/28.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "CacheManager.h"
#import <FMDatabase.h>

static CacheManager *_singletonManager = nil;

@implementation CacheManager

+(instancetype)sharedInstance{
    if (_singletonManager == nil) {
        _singletonManager = [CacheManager new];
    }
    
    return _singletonManager;
}

+(void)savePhotoWithFileName:(NSString *)fileName data:(NSData *)data{
    NSURL *fullFilePathURL = [CacheManager getFullURLWithFileName:fileName];
    
    [data writeToURL:fullFilePathURL atomically:true];
}
+(UIImage*)loadPhotoWithFileName: (NSString*) fileName{
    NSURL *fullFilePathURL = [CacheManager getFullURLWithFileName:fileName];
    
    NSData *data = [NSData dataWithContentsOfURL:fullFilePathURL];
    
    return  [UIImage imageWithData:data];
}

+(NSURL*)getFullURLWithFileName: (NSString*) fileName{
    NSArray *cachesURLs  = [[NSFileManager defaultManager]URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *targetCacheURL = cachesURLs.firstObject;
    
    NSURL *fullFilePathURL = [targetCacheURL URLByAppendingPathComponent:fileName];
    
    return fullFilePathURL;
}
@end
