//
//  Tour.m
//  PicTrip
//
//  Created by 塗政勳 on 2016/6/20.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "Tour.h"

@implementation Tour

+(instancetype)tourWithTourInfo:(NSDictionary *)tourInfo{
    
    return [[self alloc]initWithTourInfo:tourInfo];
}

-(instancetype)initWithTourInfo:(NSDictionary *)tourInfo{
    if (self = [super init]) {
        _tourID = tourInfo[@"id"];
        _tourUsername = tourInfo[@"username"];
        _tourName = tourInfo[@"tourname"];
        _tourDescription = tourInfo[@"description"];
        _tourTime = tourInfo[@"time"];
        _tourUploadDate = tourInfo[@"upload_date"];
        _tourLocations = tourInfo[@"locations"];
        _tourCoverImageID = tourInfo[@"cover_image_id"];
        _tourImages = tourInfo[@"images_id"];
        
    }
    return  self;
}
@end
