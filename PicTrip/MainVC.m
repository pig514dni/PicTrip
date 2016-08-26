//
//  MainVC.m
//  PictureMapPractice
//
//  Created by 塗政勳 on 2016/6/9.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "MainVC.h"
#import "MapViewVC.h"
#import "LeftPanelVC.h"
#import "QuartzCore/QuartzCore.h"
#define CORNER_RADIUS 4
#define SLIDE_TIMING 0.25
#define PANEL_WIDTH 140
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ProfileVC.h"
#import "TourViewController.h"
#import "ImageViewController.h"

@interface MainVC ()<MapViewVCDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong)MapViewVC *mapViewVC;
@property (nonatomic,strong)LeftPanelVC *leftPanelVC;
@property (nonatomic)BOOL showingLeftPanel;
@property (nonatomic)BOOL showPanel;
@property (nonatomic)BOOL openOrClose;
@property (nonatomic)CGPoint preVelocity;


@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
}

- (void) dealloc {
    
    NSLog(@"MainVC dealloc");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)navRefreshBtnPressed:(id)sender {
    double lat = _mapViewVC.locationManager.location.coordinate.latitude;
    double lon = _mapViewVC.locationManager.location.coordinate.longitude;
    MKCoordinateRegion region = _mapViewVC.mainMap.region;
    region.center.latitude = lat;
    region.center.longitude = lon;
    region.span.latitudeDelta = 1.0;
    region.span.longitudeDelta = 1.0;
    
    [_mapViewVC.mainMap setRegion:region];
}
- (IBAction)navSearchBtnPressed:(id)sender {
    if (_mapViewVC.searchBar.hidden) {
        //        CATransition *animation = [CATransition animation];
        //        animation.type = kCATransitionFade;
        //        animation.duration = 0.3;
        //        [_mapViewVC.searchBar.layer addAnimation:animation forKey:nil];
        //        _mapViewVC.searchBar.hidden = NO;
        
        [UIView transitionWithView:_mapViewVC.searchBar duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _mapViewVC.searchBar.hidden = NO;
        } completion:nil];
        
    } else {
        
        [UIView transitionWithView:_mapViewVC.searchBar duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _mapViewVC.searchBar.hidden = YES;
            _mapViewVC.resultTableView.hidden = YES;
        } completion:^(BOOL finished) {
            [_mapViewVC.searchBar resignFirstResponder];
        }];
    }
}

#pragma mark - Setup View
-(void)setupView{
    self.mapViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewVC"];
    self.mapViewVC.delegate = self;
    
    [self.view addSubview:self.mapViewVC.view];
    [self addChildViewController:_mapViewVC];
    
    [_mapViewVC didMoveToParentViewController:self];
    
    [self setupGestures];
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value) {
        [_mapViewVC.view.layer setCornerRadius:CORNER_RADIUS];
        [_mapViewVC.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [_mapViewVC.view.layer setShadowOpacity:0.8];
        [_mapViewVC.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
    else
    {
        [_mapViewVC.view.layer setCornerRadius:0.0f];
        [_mapViewVC.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

- (void)resetMainView
{
    // remove left view and reset variables, if needed
    if (_leftPanelVC != nil)
    {
        [self.leftPanelVC.view removeFromSuperview];
        self.leftPanelVC = nil;
        
        self.showingLeftPanel = NO;
    }
    
    
    // remove view shadows
    [self showCenterViewWithShadow:NO withOffset:0];
}

- (UIView *)getLeftView
{
    //init view if it doesn't exist
    if (_leftPanelVC == nil) {
        //this is where you define the view for the left panel
        self.leftPanelVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftPanelVC"];
        self.leftPanelVC.delegate = self;
        
        [self.view addSubview:self.leftPanelVC.view];
        
        [self addChildViewController:self.leftPanelVC];
        [_leftPanelVC didMoveToParentViewController:self];
        
        _leftPanelVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    self.showingLeftPanel = YES;
    
    //set up view shadow
    [self showCenterViewWithShadow:YES withOffset:-2];
    
    UIView *view = self.leftPanelVC.view;
    return view;
}


#pragma mark - MapViewVCDelegate
-(void)movePanelRight{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _mapViewVC.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:nil];
}
-(void)movePanelToOriginalPosition{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _mapViewVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];

}

#pragma mark - Setup Gesture
-(void)setupGestures{
    UIScreenEdgePanGestureRecognizer *edgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(openPanel:)];
    edgePanRecognizer.edges = UIRectEdgeLeft;
    [edgePanRecognizer setMinimumNumberOfTouches:1];
    [edgePanRecognizer setMaximumNumberOfTouches:1];
    [edgePanRecognizer setDelegate:self];
    
    [_mapViewVC.view addGestureRecognizer:edgePanRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(closePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [_mapViewVC.view addGestureRecognizer:panRecognizer];
    
    _openOrClose = NO;
}

-(void)openPanel:(id)sender{
    
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIScreenEdgePanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIScreenEdgePanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIScreenEdgePanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _mapViewVC.mainMap.scrollEnabled = NO;
        UIView *childView = [self getLeftView];
        
        // Make sure the view you're working with is front and center.
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIScreenEdgePanGestureRecognizer*)sender view]];
    }
    
    if([(UIScreenEdgePanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded){
        _mapViewVC.mainMap.scrollEnabled = YES;
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        if (!_showPanel) {
            [self movePanelToOriginalPosition];
            _openOrClose = NO;
        } else {
            if (_showingLeftPanel) {
                [self movePanelRight];
                _openOrClose = YES;
            }
        }
    }
    
    if([(UIScreenEdgePanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
        _showPanel = fabs([sender view].center.x - _mapViewVC.view.frame.size.width/2) > _mapViewVC.view.frame.size.width/2;
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIScreenEdgePanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
    }
    if([(UIScreenEdgePanGestureRecognizer*)sender state] == UIGestureRecognizerStateCancelled){
        _mapViewVC.mainMap.scrollEnabled = YES;
    }
}

-(void)closePanel:(id)sender{
    if (!_openOrClose) {
        return;
    }
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _mapViewVC.mainMap.scrollEnabled = NO;
        UIView *childView = [self getLeftView];
        
        // Make sure the view you're working with is front and center.
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded){
        _mapViewVC.mainMap.scrollEnabled = YES;
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        if (!_showPanel) {
            [self movePanelToOriginalPosition];
            _openOrClose = NO;
        } else {
            if (_showingLeftPanel) {
                [self movePanelRight];
                _openOrClose = YES;
            }
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
        _showPanel = fabs([sender view].center.x - _mapViewVC.view.frame.size.width/2) > _mapViewVC.view.frame.size.width/2;
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark LeftPanelVC Delegate
-(void)didSelectedFunctionWithIdentifier:(NSString *)destinationVCIdentifier{
    if ([destinationVCIdentifier isEqualToString:@"SegueToLoginViewController"]) {
        
        FBSDKAccessToken.currentAccessToken=nil;
        
        NSUserDefaults * fbUserInfo=[NSUserDefaults standardUserDefaults];
        [fbUserInfo setObject:nil forKey:@"user_id"];
        [fbUserInfo synchronize ];
        
        
        [self.mapViewVC.view removeFromSuperview];
        [self.leftPanelVC.view removeFromSuperview];
        
        [self.mapViewVC removeFromParentViewController];
        [self.leftPanelVC removeFromParentViewController];
        
        self.mapViewVC = nil;
        self.leftPanelVC = nil;
        
        UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
        UIViewController *loginVC = [loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        
            [self.navigationController dismissViewControllerAnimated:NO completion:^{
                [self dismissViewControllerAnimated:YES completion:^{
                    [self presentViewController:loginVC animated:YES completion:nil];
                }];
            }];
        
        

    }else{
        [self movePanelToOriginalPosition];
        [self performSegueWithIdentifier:destinationVCIdentifier sender:nil];
    }

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *targetID;
    if ([sender isKindOfClass:[NSString class]]) {
        targetID = sender;
    } else {
        return;
    }
    
    if ([segue.identifier isEqualToString:@"SegueToProfileVC"]) {
        ProfileVC *vc = (ProfileVC*)[segue destinationViewController];
        vc.targetUserID = targetID;
    } else if ([segue.identifier isEqualToString:@"SegueToTourView"]) {
        TourViewController *vc = [segue destinationViewController];
        vc.targetTourID = targetID;
    }
}

@end
