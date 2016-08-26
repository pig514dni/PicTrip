//
//  Function.m
//  PicTrip
//
//  Created by 塗政勳 on 2016/6/19.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "Function.h"

@implementation Function

+(instancetype)funtionWithFunctionName:(NSString*)functionName DestinationVCIdentifier:(NSString*)destinationVCIdentifier;{
    
    return [[self alloc]initWithFunctionName:functionName DestinationVCIdentifier:destinationVCIdentifier];
}


-(instancetype)initWithFunctionName:(NSString*)functionName DestinationVCIdentifier:(NSString*)destinationVCIdentifier;{
    if ((self = [super init])) {
        _functionName = functionName;
        _destinationVCIdentifier = destinationVCIdentifier;
    }
    
    return self;
}


@end
