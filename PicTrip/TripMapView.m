//
//  TripMapView.m
//  PicTrip
//
//  Created by Joe Chen on 2016/6/25.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "CoreLocation/CoreLocation.h"
#import "PicsAnnotationView.h"
#import "TripMapView.h"
#import <MapKit/MapKit.h>
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>


@interface TripMapView () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *imgsContainer;

@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(strong) PHImageManager *manager;
@property(strong) PHFetchResult *assets;
@end

@implementation TripMapView

NSMutableArray *picsInfo;
NSArray *modifyPics;
NSUserDefaults *userDefaults;
NSMutableArray *annos;
NSMutableArray *saveSelectPicsss;

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  _mapView.delegate = self;

    

  // noLocationPics = [NSMutableArray new];
  self.manager = [PHImageManager new];
  annos = [NSMutableArray new];

  picsInfo = [NSMutableArray new];
  modifyPics = [NSArray new];
  userDefaults = [NSUserDefaults standardUserDefaults];

    

  NSMutableArray *selectPicsInfo =[[userDefaults objectForKey:@"selectPicsInfo"] mutableCopy];

  if (selectPicsInfo == nil) {
    saveSelectPicsss = [NSMutableArray array];
  } else {
    saveSelectPicsss = [NSMutableArray arrayWithArray:selectPicsInfo];
  }
    
    

  PHFetchOptions *option = [PHFetchOptions new];
  option.sortDescriptors = @[
    [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]
  ];
  self.assets =
      [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];

  [self drawPicsLocation];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(modifyLocationControll:)
             name:@"modifyLocationControll"
           object:nil];
   
    [self checkMapViewSize];
}
- (IBAction)backToUpdateTrip:(UIButton *)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)modifyLocationControll:(NSNotification *)notifacation {

  UILongPressGestureRecognizer *longPressGesture =
      [[UILongPressGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(handleLongPressGesture:)];
    
  [self.mapView addGestureRecognizer:longPressGesture];
}

- (void)handleLongPressGesture:(UIGestureRecognizer *)sender {

    NSMutableArray *noLocationDafault =[[userDefaults objectForKey:@"modifiedLocation"]mutableCopy];

    
    // This is important if you only want to receive one tap and hold event
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.mapView removeGestureRecognizer:sender];

    } else {
    
      
        if (noLocationDafault != nil) {
            modifyPics = [NSArray arrayWithArray:noLocationDafault];
        }
      
            NSNumber *picsIndex = modifyPics[1];
            CGPoint point = [sender locationInView:self.mapView];
            CLLocationCoordinate2D locCoord =[self.mapView convertPoint:point toCoordinateFromView:self.mapView];
      
            PicsAnnotationView *picsAnno =[[PicsAnnotationView alloc] initWithCoordinate:locCoord];
            picsAnno.name = picsIndex.stringValue;
        
            [_mapView addAnnotation:picsAnno];
            [self.mapView removeGestureRecognizer:sender];

        for (int i = 0; i < saveSelectPicsss.count; i++) {
            NSMutableDictionary *temp =[[saveSelectPicsss objectAtIndex:i] mutableCopy];
            NSNumber *index = [temp objectForKey:@"index"];

            if (picsIndex.integerValue == index.integerValue) {
        
                NSString *imageName = [temp objectForKey:@"name"];
                NSNumber *index = [temp objectForKey:@"index"];
                NSString *lat = [NSString stringWithFormat:@"%f", locCoord.latitude];
                NSString *lon = [NSString stringWithFormat:@"%f", locCoord.longitude];

                [temp removeAllObjects];
                [temp setObject:index forKey:@"index"];
                [temp setObject:imageName forKey:@"name"];
                [temp setObject:lat forKey:@"latitude"];
                [temp setObject:lon forKey:@"longitude"];
                
                NSLog(@"%@", temp);
                
                [saveSelectPicsss removeObjectAtIndex:i];
                [saveSelectPicsss addObject:temp];
                
                [noLocationDafault removeAllObjects];
                
                [[NSUserDefaults standardUserDefaults] setObject:saveSelectPicsss
                                                          forKey:@"selectPicsInfo"];
                [[NSUserDefaults standardUserDefaults] setObject:noLocationDafault
                                                          forKey:@"modifiedLocation"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
     [self checkMapViewSize];
        
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"finishLocationModify"
                      object:nil];
  }
}

-(void)checkMapViewSize{
    
        for (int i = 0; i < saveSelectPicsss.count; i++) {
            NSMutableDictionary *temp = [saveSelectPicsss objectAtIndex:i];
            NSString *lat = [temp objectForKey:@"latitude"];
            NSString *lon = [temp objectForKey:@"longtitude"];
            
            if ([lat isEqualToString:@"0.000000"] ||
                [lon isEqualToString:@"0.000000"]) {
                [self.view bringSubviewToFront:_imgsContainer];
                return;
            }else{
               
                [self.view sendSubviewToBack:_imgsContainer];
            }
        }
}

- (void)mapView:(MKMapView *)mapView
        annotationView:(MKAnnotationView *)view
    didChangeDragState:(MKAnnotationViewDragState)newState
          fromOldState:(MKAnnotationViewDragState)oldState {
//    PicsAnnotationView * pics = (PicsAnnotationView*)view;
    
//    NSLog(@"%@",pics.lala);
    
   // NSMutableArray *noLocationDafault =[[userDefaults objectForKey:@"modifiedLocation"]mutableCopy];

    
    PicsAnnotationView * anno = (PicsAnnotationView*)view.annotation;
    NSLog(@"%@",anno.name);
    
        NSInteger picsIndex = [[anno name]integerValue];
    
    if (newState == MKAnnotationViewDragStateEnding) {

        CLLocationCoordinate2D location = [view.annotation coordinate];
        NSLog(@"%f,%f", location.latitude, location.longitude);
    
        
    
    for (int i = 0; i < saveSelectPicsss.count; i++) {
        NSMutableDictionary *temp =[[saveSelectPicsss objectAtIndex:i] mutableCopy];
        NSNumber *index = [temp objectForKey:@"index"];
        
        if (picsIndex == index.integerValue) {
            CLLocationCoordinate2D location = [view.annotation coordinate];
            NSString *imageName = [temp objectForKey:@"name"];
            NSNumber *index = [temp objectForKey:@"index"];
            NSString *lat = [NSString stringWithFormat:@"%f", location.latitude];
            NSString *lon = [NSString stringWithFormat:@"%f", location.longitude];
            
            [temp removeAllObjects];
            [temp setObject:index forKey:@"index"];
            [temp setObject:imageName forKey:@"name"];
            [temp setObject:lat forKey:@"latitude"];
            [temp setObject:lon forKey:@"longitude"];
            
            
            
            [saveSelectPicsss removeObjectAtIndex:i];
            [saveSelectPicsss addObject:temp];
            
            NSLog(@"%@",temp);
            
            
            [[NSUserDefaults standardUserDefaults] setObject:saveSelectPicsss
                                                      forKey:@"selectPicsInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [view setDragState:MKAnnotationViewDragStateNone animated:YES];
        }
    }
        
    }
    
    
}

- (void)drawPicsLocation {

  for (int i = 0; i < saveSelectPicsss.count; i++) {

    NSMutableDictionary *temp = [saveSelectPicsss objectAtIndex:i];
    NSNumber *picsIndex = [temp objectForKey:@"index"];
    CLLocationDegrees lat = [[temp objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon = [[temp objectForKey:@"longitude"] doubleValue];

    CLLocationCoordinate2D picsLication = CLLocationCoordinate2DMake(lat, lon);

    if (lat != 0.000000 && lon != 0.000000) {

      PicsAnnotationView *picsAnno =
          [[PicsAnnotationView alloc] initWithCoordinate:picsLication];
      picsAnno.name = [NSString stringWithFormat:@"%@",picsIndex];
        NSLog(@"%@",picsAnno.name);

      MKCoordinateRegion region =_mapView.region; // region代表地圖的中心和縮放大小
      region.center = picsLication;
      region.span.latitudeDelta = 1; //地圖上看最上緣跟最下緣相差0.01緯度
      region.span.longitudeDelta = 1; //...
      [_mapView setRegion:region animated:true];

      [annos addObject:picsAnno];
    }
  }
  [_mapView addAnnotations:annos];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {

  static NSString *picsAnnotationIdentifier = @"picsAnnotationIdentifier";

  if ([annotation isKindOfClass:[PicsAnnotationView class]]) {

    // Try to get an unused annotation, similar to uitableviewcells
    MKAnnotationView *annotationView = [mapView
        dequeueReusableAnnotationViewWithIdentifier:picsAnnotationIdentifier];
    // If one isn't available, create a new one
    if (!annotationView) {
      annotationView = [[MKAnnotationView alloc]
          initWithAnnotation:annotation
             reuseIdentifier:picsAnnotationIdentifier];

      annotationView.draggable = YES;

      for (int i = 0; i < saveSelectPicsss.count; i++) {
        NSMutableDictionary *temp = [saveSelectPicsss objectAtIndex:i];
        NSNumber *picsIndex = [temp objectForKey:@"index"];
        if (((PicsAnnotationView *)annotation).name == picsIndex.stringValue) {

          PHAsset *asset = self.assets[picsIndex.intValue];

          [self.manager requestImageForAsset:asset
                                  targetSize:CGSizeMake(50, 50)
                                 contentMode:PHImageContentModeAspectFit
                                     options:nil
                               resultHandler:^(UIImage *_Nullable result,
                                               NSDictionary *_Nullable info) {

                                 annotationView.image = result;
                                 annotationView.layer.cornerRadius = 8;

                               }];
        }
      }
    }
    return annotationView;
  }
  return nil;
}

- (UIImage *)imageCompressWithSimple:(UIImage *)image
                        scaledToSize:(CGSize)size {
  UIGraphicsBeginImageContext(size);
  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)mspTypeChange:(UISegmentedControl*)sender {
    
    NSInteger targetIndex = sender.selectedSegmentIndex;
    
    switch (targetIndex) {
        case 0:
            _mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            _mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
