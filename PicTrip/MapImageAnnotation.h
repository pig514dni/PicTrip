//
//  MapImageAnnotation.h
//  PicTrip
//
//  Created by 塗政勳 on 2016/7/20.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapImageAnnotation : MKPointAnnotation
@property (nonatomic,strong)NSDictionary *imageInfo;

@end
