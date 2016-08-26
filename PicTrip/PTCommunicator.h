//
//  PTCommunicator.h
//  MysqlUploadTest
//
//  Created by 塗政勳 on 2016/7/3.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define USERNAME_KEY @"username"
#define TOURNAME_KEY @"tourname"
#define USER_ID_KEY @"user_id"
#define TOUR_ID_KEY @"tour_id"
#define PROFILE_NAME_KEY @"profile_name"
#define DESCRIPTION_KEY @"description"
#define TIME_KEY @"time"
#define UPLOAD_DATE_KEY @"upload_time"
#define LATITUDE_KEY @"lat"
#define LONGITUDE_KEY @"lon"
#define FILTER_KEY @"filter"

typedef void(^CompletionHandler)(NSError *error,id result);

@interface PTCommunicator : NSObject

+(instancetype)sharedInstance;

//generate info dictionary
-(NSDictionary*)generateTourInfoWithUerID:(NSString*)userID tourname:(NSString*)tourname description:(NSString*)description;
-(NSDictionary*)generateImageInfoWithUserID:(NSString*)userID filename:(NSString*)filename tourID:(NSString*)tourID description:(NSString*)description time:(NSTimeInterval)time lat:(NSString*)lat lon:(NSString*)lon;
-(NSDictionary*)generateCommentInfoWithUserID:(NSString*)userID targetID:(NSString*)targetID content:(NSString*)content targetType:(NSString*)targetType;
-(NSDictionary*)generateFbUserInfoWithFbID:(NSString*)fbID email:(NSString*)email profileName:(NSString*)profileName;
-(NSDictionary*)generateUserInfoWithUsername:(NSString*)username password:(NSString*)password name:(NSString*)name email:(NSString*)email sex:(NSString*)sex country:(NSString*)country question:(NSString*)question answer:(NSString*)answer;

//actions with users
-(void)getUserInfoWithUserID:(NSString *)userID completion:(CompletionHandler)completionHandler;
-(void)getUserIDWithFBID:(NSString *)FBID completion:(CompletionHandler)completionHandler;
-(void)registerWithFbUserInfo:(NSDictionary*)fbUserInfo profileImage:(NSData*)profileImage completion:(CompletionHandler)completionHandler;
-(void)registerWithUserInfo:(NSDictionary*)userInfo completion:(CompletionHandler)completionHandler;
-(void)loginWithUsername:(NSString*)username password:(NSString*)password completion:(CompletionHandler)completionHandler;

//actions with tours
-(void)checkTourWithUserID:(NSString*)userID tourname:(NSString*)tourname completion:(CompletionHandler)completionHandler;
-(void)createTourWithTourInfo:(NSDictionary*)tourInfo completion:(CompletionHandler)completionHandler;
-(void)getTourInfoWithTourID:(NSString *)tourID completion:(CompletionHandler)completionHandler;

//actions with images
typedef NS_ENUM(NSInteger, PTTopImageFilter){
    PTTopImageFilterHit = 0,
    PTTopImageFilterUploadTime = 1,
    
};
-(void)getTopImagesWithFilter:(PTTopImageFilter)filter numberOfImages:(NSString*)number completion:(CompletionHandler)completionHandler;
-(void)uploadImageWithImage:(UIImage*)image imageInfo:(NSDictionary*) imageInfo completion:(CompletionHandler)completionHandler;
-(void)uploadProfileImageWithImage:(UIImage*)image userID:(NSString*) userID completion:(CompletionHandler)completionHandler;
-(void)downloadImageWithFilename:(NSString*)filename completion:(CompletionHandler)completionHandler;
-(void)downloadImageWithImageID:(NSString*)imageID completion:(CompletionHandler) completionHandler;
-(void)downloadProfileImageWithImageID:(NSString*)profileImageID completion:(CompletionHandler)completionHandler;
-(void)getImageInfoWithImageID:(NSString*)imageID completion:(CompletionHandler) completionHandler;

//actions with likes
-(void)uploadLikeWithUserID:(NSString*)userID targetID:(NSString*)targetID targetType:(NSString*)targetType completion:(CompletionHandler)completionHandler;
-(void)getLikesWithTargetID:(NSString*)targetID targetType:(NSString*)targetType completion:(CompletionHandler)completionHandler;
-(void)checkLikeWithUserID:(NSString*)userID targetID:(NSString*)targetID targetType:(NSString*)targetType completion:(CompletionHandler)completionHandler;

//actions with comments
-(void)uploadCommentWithCommentInfo:(NSDictionary*)commentInfo completion:(CompletionHandler)completionHandler;
-(void)getCommentsWithTargetID:(NSString*)targetID targetType:(NSString*)targetType completion:(CompletionHandler)completionHandler;


@end

