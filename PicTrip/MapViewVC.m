//
//  MapViewVC.m
//  PictureMapPractice
//
//  Created by 塗政勳 on 2016/6/2.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "MapViewVC.h"
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"
#import "PTCommunicator.h"
#import "MapImageAnnotation.h"
#import "MapImageAnnotationView.h"
#import "MapDetailCallout.h"
#import "ProfileVC.h"

@interface MapViewVC ()<CLLocationManagerDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) PTCommunicator *comm;
@property (nonatomic,strong) NSMutableArray *placemarks;
@property (nonatomic,strong) NSMutableDictionary *topImages;
@property (nonatomic) dispatch_once_t locationOnceToken;

@end

@implementation MapViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _comm = [PTCommunicator sharedInstance];
    
    _resultTableView.hidden = YES;
    _searchBar.hidden = YES;
    
    [self setupLocationManager];
    [self setupAnnotations];
    [self setupGestureRecognizer];
    _locationOnceToken = 0;
    
}

- (void) dealloc {
    
    NSLog(@"MapViewVC dealloc");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupAnnotations{
    _topImages = [NSMutableDictionary new];
    [_comm getTopImagesWithFilter:PTTopImageFilterHit numberOfImages:@"3" completion:^(NSError *error, id result) {
        if ([result[@"result"]boolValue]) {
            
            NSArray *images = result[@"images"];
            for (int i=0; i<images.count; i+=1) {
                MapImageAnnotation *annotation = [MapImageAnnotation new];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(((NSString*)images[i][@"lat"]).doubleValue,((NSString*)images[i][@"lon"]).doubleValue );
                annotation.coordinate = coord;
                annotation.imageInfo = images[i];
                [_mainMap addAnnotation:annotation];
            }
            
        } else {
            NSLog(@"error: %@",error? error:result);
        }
    }];
}

-(void)setupLocationManager{
    _locationManager = [CLLocationManager new];
    if([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.activityType = CLActivityTypeFitness;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}

-(void)setupGestureRecognizer{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTappedMap)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setNumberOfTapsRequired:1];
    
    [_mainMap addGestureRecognizer:tapRecognizer];
    
}

-(void)didTappedMap{
    _resultTableView.hidden = YES;
    [_searchBar resignFirstResponder];
}
#pragma mark - CLLocation Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = locations.lastObject;
    double lat = location.coordinate.latitude;
    double lon = location.coordinate.longitude;
    
    dispatch_once(&_locationOnceToken, ^{
        MKCoordinateRegion region = _mainMap.region;
        region.center.latitude = lat;
        region.center.longitude = lon;
        region.span.latitudeDelta = 1.0;
        region.span.longitudeDelta = 1.0;
    
        [_mainMap setRegion:region];
    });
   
    
}
#pragma mark - UISearchBar Delegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (searchBar.text.length > 0) {
        [self searchBar:searchBar textDidChange:searchBar.text];
    }
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _resultTableView.hidden = NO;
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc]init];
    searchRequest.naturalLanguageQuery = searchText;
    searchRequest.region = self.mainMap.region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:searchRequest];
    self.placemarks = [NSMutableArray array];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        for (MKMapItem *item in response.mapItems) {
            [_placemarks addObject:item.placemark];
        }
        
        [_resultTableView reloadData];

    }];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self.mainMap removeAnnotations:[self.mainMap annotations]];
    [self.mainMap showAnnotations:_placemarks animated:NO];
    _resultTableView.hidden = YES;
}

#pragma mark - TableView datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.placemarks.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [_resultTableView dequeueReusableCellWithIdentifier:@"MapSearchResultCell" forIndexPath:indexPath];
    
    MKPlacemark *placemark = _placemarks[indexPath.row];
    NSDictionary *locationDetail = placemark.addressDictionary;
    NSArray *formattedAddressArray = locationDetail[@"FormattedAddressLines"];
    NSString *fullAddress = @"";
    for (NSString *string in formattedAddressArray) {
        fullAddress = [fullAddress stringByAppendingString:string];
    }
    
    cell.textLabel.text = placemark.name;
    cell.detailTextLabel.text = fullAddress;
    
    return cell;
}

#pragma mark Tableview Delegate 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchBar resignFirstResponder];
    _resultTableView.hidden = YES;
    
    MKPlacemark *placemark = _placemarks[indexPath.row];
    double lat = placemark.coordinate.latitude;
    double lon = placemark.coordinate.longitude;
    
    MKCoordinateRegion region = _mainMap.region;
    region.center.latitude = lat;
    region.center.longitude = lon;
    region.span.latitudeDelta = 0.1;
    region.span.longitudeDelta = 0.1;
    
    [_mainMap removeAnnotations:_mainMap.annotations];
    [_mainMap addAnnotation:placemark];
    [_mainMap setRegion:region];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - MKMapView Delegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if(annotation == mapView.userLocation){
        return nil;
    }
    MKAnnotationView *annoView;
    
    BOOL isSearchResult = [annotation isKindOfClass:NSClassFromString(@"MKPlacemark")];
    
    if (!isSearchResult && [annotation isKindOfClass:NSClassFromString(@"MapImageAnnotation")]) {
        
        MapImageAnnotation *anno = annotation;
        NSString *identifier = @"TopImage";
        anno.title = @" ";
        
        MapImageAnnotationView *topAnnoView = (MapImageAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

        if(topAnnoView == nil){
            //Create a annotation view
            topAnnoView = [[MapImageAnnotationView alloc]initWithAnnotation:anno reuseIdentifier:identifier];
        }else{
            topAnnoView.annotation = anno;
        }

        topAnnoView.canShowCallout = true;
        topAnnoView.detailCallout = [MapDetailCallout new];
        topAnnoView.detailCallout.view.frame = CGRectMake(0, 0, 80, 80);
        topAnnoView.detailCalloutAccessoryView = topAnnoView.detailCallout.view;        
        
        [_comm getUserInfoWithUserID:anno.imageInfo[@"user_id"] completion:^(NSError *error, id result) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"MM/dd"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[topAnnoView.detailCallout.imageInfo[@"upload_time"]doubleValue]];
            topAnnoView.detailCallout.imageInfoLabel.text = [NSString stringWithFormat:@"Posted by %@ on %@",result[@"userInfo"][@"profile_name"],[formatter stringFromDate:date]];
            
        }];
        
        topAnnoView.detailCallout.imageInfo = anno.imageInfo;
        topAnnoView.detailCallout.vc = self.parentViewController;
        
        [_comm downloadImageWithImageID:topAnnoView.detailCallout.imageInfo[@"id"] completion:^(NSError *error, id result) {
            if (result) {
                
                topAnnoView.detailCallout.imageView.clipsToBounds = true;
                topAnnoView.detailCallout.imageView.image = result;
            }
        }];
        
        topAnnoView.image = [UIImage imageNamed:@"pointRed.png"];
        annoView = (MKAnnotationView*)topAnnoView;
    
    } else {
        NSString *identifier = @"SearchResult";
        
        annoView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if(annoView == nil){
            //Create a annotation view
            annoView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        }else{
            annoView.annotation = annotation;
        }
        
        annoView.canShowCallout = true;
    }
    
    return annoView;
}

//-(void)viewProfileBtnPressed:(UIButton*)sender{
//    MapDetailCallout *callout = (MapDetailCallout*)[sender.superview ];
//    NSString *userID = callout.imageInfo[@"user_id"];
//    ProfileVC *vc = [ProfileVC new];
//    vc.targetUserID = userID;
//    [self.parentViewController.navigationController showViewController:vc sender:nil];
//    NSLog(@"tapped");
//}

         
         
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
