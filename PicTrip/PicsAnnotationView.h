//
//  PicsAnnotationView.h
//  PicTrip
//
//  Created by Joe Chen on 2016/6/25.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PicsAnnotationView : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic,strong) NSString * lala;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D) coord;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@end
