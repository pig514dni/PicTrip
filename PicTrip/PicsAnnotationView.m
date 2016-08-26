//
//  PicsAnnotationView.m
//  PicTrip
//
//  Created by Joe Chen on 2016/6/25.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "PicsAnnotationView.h"

@implementation PicsAnnotationView
@synthesize coordinate;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id) initWithCoordinate:(CLLocationCoordinate2D) coord{
    
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    
        coordinate = newCoordinate;
}

@end
