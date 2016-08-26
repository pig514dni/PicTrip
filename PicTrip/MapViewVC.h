//
//  MapViewVC.h
//  PictureMapPractice
//
//  Created by 塗政勳 on 2016/6/2.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"


@protocol MapViewVCDelegate <NSObject>

@optional
- (void)movePanelLeft;
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;
@end

@interface MapViewVC : UIViewController<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mainMap;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic) id<MapViewVCDelegate> delegate;

@end
