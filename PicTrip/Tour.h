//
//  Tour.h
//  PicTrip
//
//  Created by 塗政勳 on 2016/6/20.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tour : NSObject

@property (nonatomic,strong)NSString *tourID;
@property (nonatomic,strong)NSString *tourUsername;
@property (nonatomic,strong)NSString *tourName;
@property (nonatomic,strong)NSString *tourDescription;
@property (nonatomic,strong)NSMutableArray *tourLocations;
@property (nonatomic,strong)NSMutableArray *tourTime;
@property (nonatomic,strong)NSString *tourCoverImageID;
@property (nonatomic,strong)NSMutableArray *tourImages;
@property (nonatomic,strong)NSString *tourUploadDate;

+(instancetype)tourWithTourInfo:(NSDictionary*)tourInfo;
-(instancetype)initWithTourInfo:(NSDictionary*)tourInfo;
@end
