////
////  PhotoTableViewController.m
////  PicTrip
////
////  Created by 張峻綸 on 2016/7/3.
////  Copyright © 2016年 塗政勳. All rights reserved.
////
//
//#import "PhotoTableViewController.h"
//#import "PhotoTableViewCell.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
//@interface PhotoTableViewController ()
//{
//    NSArray * imageArray;
//    UIImage *test;
//    FBSDKProfilePictureView *fbImage;
//    NSMutableArray *selectArray;
//    NSString *tmp;
//}
//@property (strong, nonatomic) IBOutlet UITableView *photoTableView;
//
//@end
//
//@implementation PhotoTableViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    imageArray = @[@"pig.jpg",@"japan",@"3.jpg"];
//    selectArray =[NSMutableArray new];
//    tmp=@"test";
//    
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//    
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}
//
////-(void)viewDidLayoutSubviews
////{
////
////}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
////#warning Incomplete implementation, return the number of sections
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
////#warning Incomplete implementation, return the number of rows
//    return 1;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    cell.userImage.clipsToBounds=YES;
//    cell.userImage.layer.cornerRadius=CGRectGetWidth(cell.userImage.frame)/2;
//    cell.userImage.image=[UIImage imageNamed:imageArray[0]];
//    
//    cell.imageDescription.text=imageArray[1];
//    
//    UIImage *aaaa =[UIImage imageNamed:@"3.JPG"];
//    CGSize aaa;
//    aaa.width=[UIScreen mainScreen].bounds.size.width;
//    float number=aaa.width/aaaa.size.width;
//    aaa.height=aaaa.size.height*number;
////    CGRect aaa;
////    aaa.size.width=self.view.bounds.origin.x;
////    aaa.size.height=200;
//    
//    cell.postImage.image=[self  imageWithImage:aaaa scaledToSize:aaa];
//    
////    if (indexPath.row==0) {
////        if (cell.likeButton.selected) {
////            cell.likeButton.selected=NO;
////        }else{
////            cell.likeButton.selected=YES;
////        }
////        
////    }
//    // Configure the cell...
//    
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//
//    
//}
//- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
//{
//    // Create a graphics image context
//    UIGraphicsBeginImageContext(newSize);
//    
//    // Tell the old image to draw in this new context, with the desired
//    // new size
//    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    
//    // Get the new image from the context
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    // End the context
//    UIGraphicsEndImageContext();
//    
//    // Return the new image.
//    return newImage;
//}
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
///*
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}
//*/
//
///*
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
//}
//*/
//
///*
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}
//*/
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//@end
