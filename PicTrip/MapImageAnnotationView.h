//
//  MapImageAnnotationView.h
//  PicTrip
//
//  Created by 塗政勳 on 2016/7/23.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapDetailCallout.h"

@interface MapImageAnnotationView : MKAnnotationView
@property (nonatomic,strong) MapDetailCallout *detailCallout;

@end
