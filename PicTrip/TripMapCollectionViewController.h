//
//  TripMapCollectionViewController.h
//  PicTrip
//
//  Created by Joe Chen on 2016/6/25.
//  Copyright © 2016年 塗政勳. All rights reserved.
//
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@interface TripMapCollectionViewController : UICollectionViewController


@property(strong) PHCachingImageManager *noLocationManager;
@property(strong) PHFetchResult *noLocationAssets;
@property(strong) PHFetchResult *assets;

@end
