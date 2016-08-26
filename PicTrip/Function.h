//
//  Function.h
//  PicTrip
//
//  Created by 塗政勳 on 2016/6/19.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Function : NSObject

@property (nonatomic,strong)NSString *functionName;
@property (nonatomic,strong)NSString *destinationVCIdentifier;


+(instancetype)funtionWithFunctionName:(NSString*)functionName DestinationVCIdentifier:(NSString*)destinationVCIdentifier;
-(instancetype)initWithFunctionName:(NSString*)functionName DestinationVCIdentifier:(NSString*)destinationVCIdentifier;
@end
