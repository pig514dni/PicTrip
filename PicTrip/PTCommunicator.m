//
//  PTCommunicator.m
//  MysqlUploadTest
//
//  Created by 塗政勳 on 2016/7/3.
//  Copyright © 2016年 塗政勳. All rights reserved.
//

#import "PTCommunicator.h"
#import <AFNetworking.h>
#import "CacheManager.h"

////for server
//#define BASE_URL @"http://ec2-52-197-113-254.ap-northeast-1.compute.amazonaws.com"

//for local test
#define BASE_URL @"http://localhost:8888"

#define GET_TOP_IMAGES_URL [BASE_URL stringByAppendingPathComponent:@"get_top3_images.php"]
#define IMAGE_DIR_URL [BASE_URL stringByAppendingPathComponent:@"photo"]
#define PROFILE_IMAGE_DIR_URL [BASE_URL stringByAppendingPathComponent:@"profile_image"]
#define CHECK_TOUR_URL [BASE_URL stringByAppendingPathComponent:@"check_tour.php"]
#define CREATE_TOUR_URL [BASE_URL stringByAppendingPathComponent:@"create_tour.php"]
#define UPLOAD_IMAGE_URL [BASE_URL stringByAppendingPathComponent:@"upload_image.php"]
#define UPLOAD_PROFILE_IMAGE_URL [BASE_URL stringByAppendingPathComponent:@"upload_profile_image.php"]
#define GET_TOURINFO_URL [BASE_URL stringByAppendingPathComponent:@"get_tourInfo.php"]
#define GET_USERINFO_URL [BASE_URL stringByAppendingPathComponent:@"get_userInfo.php"]
#define GET_USERID_WITH_FBID_URL [BASE_URL stringByAppendingPathComponent:@"get_userid_by_fbid.php"]
#define GET_IMAGEINFO_URL [BASE_URL stringByAppendingPathComponent:@"get_imageInfo.php"]
#define COMMENT_URL [BASE_URL stringByAppendingPathComponent:@"comment.php"]
#define LIKE_URL [BASE_URL stringByAppendingPathComponent:@"like.php"]
#define GET_COMMENTS_URL [BASE_URL stringByAppendingPathComponent:@"get_comments.php"]
#define GET_LIKES_URL [BASE_URL stringByAppendingPathComponent:@"get_likes.php"]
#define CHECK_LIKE_URL [BASE_URL stringByAppendingPathComponent:@"check_like.php"]
#define FBUSER_REGISTER_URL [BASE_URL stringByAppendingPathComponent:@"register_as_fbuser.php"]
#define GET_PROFILE_IMAGE_FILENAME_URL [BASE_URL stringByAppendingPathComponent:@"get_profile_image_filename.php"]
#define REGISTER_URL [BASE_URL stringByAppendingPathComponent:@"register.php"]
#define LOGIN_URL [BASE_URL stringByAppendingPathComponent:@"login.php"]

static PTCommunicator *_singletonCommunicator = nil;

@implementation PTCommunicator

+(instancetype)sharedInstance{
    if (_singletonCommunicator == nil) {
        _singletonCommunicator = [PTCommunicator new];
    }
    
    return _singletonCommunicator;
}

-(NSDictionary *)generateTourInfoWithUerID:(NSString *)userID tourname:(NSString *)tourname description:(NSString *)description{
    NSTimeInterval uploadTime = [[NSDate date] timeIntervalSince1970];
    NSDictionary *result = @{USER_ID_KEY:userID,TOURNAME_KEY:tourname,DESCRIPTION_KEY:description,UPLOAD_DATE_KEY:@(uploadTime)};
    return result;
}

-(NSDictionary *)generateImageInfoWithUserID:(NSString *)userID filename:(NSString *)filename tourID:(NSString *)tourID description:(NSString *)description time:(NSTimeInterval)time lat:(NSString *)lat lon:(NSString *)lon{
    NSTimeInterval uploadTime = [[NSDate date] timeIntervalSince1970];
    NSDictionary *result = @{USER_ID_KEY:userID,TOUR_ID_KEY:tourID,DESCRIPTION_KEY:description,TIME_KEY:@(time),UPLOAD_DATE_KEY:@(uploadTime),LATITUDE_KEY:lat,LONGITUDE_KEY:lon,@"filename":filename};
    return result;
}

-(NSDictionary *)generateCommentInfoWithUserID:(NSString *)userID targetID:(NSString *)targetID content:(NSString *)content targetType:(NSString *)targetType{
    NSTimeInterval uploadTime = [[NSDate date] timeIntervalSince1970];
    NSDictionary *result = @{USER_ID_KEY:userID,@"target_id":targetID,@"content":content,UPLOAD_DATE_KEY:@(uploadTime),@"target_type":targetType};
    return result;
}

-(NSDictionary *)generateFbUserInfoWithFbID:(NSString *)fbID email:(NSString *)email profileName:(NSString *)profileName{
    NSTimeInterval uploadTime = [[NSDate date] timeIntervalSince1970];
    NSDictionary *result = @{@"fb_id":fbID,@"email":email,@"profile_name":profileName,@"register_time":@(uploadTime)};
    return result;
}

-(NSDictionary*)generateUserInfoWithUsername:(NSString*)username password:(NSString*)password name:(NSString*)name email:(NSString*)email sex:(NSString*)sex country:(NSString*)country question:(NSString*)question answer:(NSString*)answer{
    NSTimeInterval registerTime = [[NSDate date] timeIntervalSince1970];
    NSDictionary *userInfo = @{@"username":username,@"password":password,@"profile_name":name, @"email":email,@"sex":sex,@"country":country,@"question":question,@"answer":answer,@"register_time":@(registerTime)};
    return userInfo;
}

-(void)checkTourWithUserID:(NSString *)userID tourname:(NSString *)tourname completion:(CompletionHandler)completionHandler{
    NSDictionary *itemsToCheck = @{USER_ID_KEY:userID,TOURNAME_KEY:tourname};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:CHECK_TOUR_URL parameters:itemsToCheck progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST check_tour.php OK Result: %@",responseObject); 
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doPOST check_tour.php Error: %@",error);
        completionHandler(error,nil);
        
    }];
}
-(void)createTourWithTourInfo:(NSDictionary *)tourInfo completion:(CompletionHandler)completionHandler{
    NSData *tourInfoData = [NSJSONSerialization dataWithJSONObject:tourInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *tourInfoString = [[NSString alloc]initWithData:tourInfoData encoding:NSUTF8StringEncoding];
    NSDictionary *tourInfoParamaters = @{@"data":tourInfoString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:CREATE_TOUR_URL parameters:tourInfoParamaters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST create_tour.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doPOST create_tour.php Error: %@",error);
        completionHandler(error,nil);
    }];
    
}
-(void)uploadImageWithImage:(UIImage *)image imageInfo:(NSDictionary *)imageInfo completion:(CompletionHandler)completionHandler{
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSData *imageInfoData = [NSJSONSerialization dataWithJSONObject:imageInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *imageInfoString = [[NSString alloc]initWithData:imageInfoData encoding:NSUTF8StringEncoding];
    NSDictionary *imageInfoParameters = @{@"data":imageInfoString};
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:UPLOAD_IMAGE_URL parameters:imageInfoParameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"fileToUpload" fileName:imageInfo[@"filename"] mimeType:@"image/jpg"];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST upload_image.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doPOST upload_image.php Error: %@",error);
        completionHandler(error,nil);
        
    }];
}

-(void)uploadProfileImageWithImage:(UIImage *)image userID:(NSString *)userID completion:(CompletionHandler)completionHandler{
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSDictionary *idParameter = @{@"user_id":userID};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:UPLOAD_PROFILE_IMAGE_URL parameters:idParameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"fileToUpload" fileName:[NSString stringWithFormat:@"%@.JPG",userID] mimeType:@"image/jpg"];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST upload_profile_image.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doPOST upload_profile_image.php Error: %@",error);
        completionHandler(error,nil);
        
    }];
}

- (void)downloadImageWithFilename:(NSString*)filename completion:(CompletionHandler)completionHandler{
    
    UIImage *resultImg = [CacheManager loadPhotoWithFileName:filename];
    if (resultImg) {
        NSLog(@"Load '%@' succeed.",filename);
        completionHandler(nil,resultImg);
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"];
    NSString *urlstring = [IMAGE_DIR_URL stringByAppendingPathComponent:filename];
    
    [manager GET:urlstring parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Download Image'%@' OK: %lu bytes", filename, [responseObject length]);
        UIImage *image = [UIImage imageWithData:responseObject];
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSLog(@"save '%@' succeed.",filename);
            [CacheManager savePhotoWithFileName:filename data:responseObject];
        }
        completionHandler(nil,image);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Download Image'%@' Fail: %@", filename, error);
        completionHandler(error,nil);
    }];
    
}

-(void)downloadImageWithImageID:(NSString *)imageID completion:(CompletionHandler)completionHandler{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"];
    
    [self getImageInfoWithImageID:imageID completion:^(NSError *error, id result) {
        NSString *urlstring = [IMAGE_DIR_URL stringByAppendingPathComponent:result[@"imageInfo"][@"filename"]];
        
        UIImage *resultImg = [CacheManager loadPhotoWithFileName:result[@"imageInfo"][@"filename"]];
        if (resultImg) {
            NSLog(@"Load '%@' succeed.",result[@"imageInfo"][@"filename"]);
            completionHandler(nil,resultImg);
            return;
        }
        
        [manager GET:urlstring parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"Download Image'%@' OK: %lu bytes", imageID, [responseObject length]);
            if ([responseObject isKindOfClass:[NSData class]]) {
                NSLog(@"save '%@' succeed.",result[@"imageInfo"][@"filename"]);
                [CacheManager savePhotoWithFileName:result[@"imageInfo"][@"filename"] data:responseObject];
            }
            UIImage *image = [UIImage imageWithData:responseObject];
            completionHandler(nil,image);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Download Image'%@' Fail: %@", imageID, error);
            completionHandler(error,nil);
        }];
    }];
}

-(void)downloadProfileImageWithImageID:(NSString *)profileImageID completion:(CompletionHandler)completionHandler{
    NSDictionary *parameter = @{@"profile_image_id":profileImageID};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_PROFILE_IMAGE_FILENAME_URL parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if (responseObject[@"filename"]) {
            NSString *filename = responseObject[@"filename"];
            UIImage *resultImg = [CacheManager loadPhotoWithFileName:responseObject[@"filename"]];
            if (resultImg) {
                NSLog(@"Load '%@' succeed.",responseObject[@"filename"]);
                completionHandler(nil,resultImg);
                return;
            }
            
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"];
            
                NSString *urlstring = [PROFILE_IMAGE_DIR_URL stringByAppendingPathComponent:responseObject[@"filename"]];
                
                [manager GET:urlstring parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"Download ProfileImage'%@' OK: %lu bytes", profileImageID, [responseObject length]);
                    
                    if ([responseObject isKindOfClass:[NSData class]]) {
                        NSLog(@"save '%@' succeed.",filename);
                        [CacheManager savePhotoWithFileName:filename data:responseObject];
                    }
                    
                    UIImage *image = [UIImage imageWithData:responseObject];
                    completionHandler(nil,image);
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"Download ProfileImage'%@' Fail: %@", profileImageID, error);
                    completionHandler(error,nil);
                }];

        } else {
            NSLog(@"GET PROFILE IMAGE FILENAME ERROR: %@",responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET DownloadProfileImage Error: %@",error);
        completionHandler(error,nil);
    }];

}



-(NSString*)topImageFilterTransfer:(PTTopImageFilter)filter{
    NSString *result;
    switch (filter) {
        case PTTopImageFilterHit:
            result = @"hit";
            break;
        case PTTopImageFilterUploadTime:
            result = @"upload_time";
            break;
        default:
            result = @"hit";
            break;
    }
    return result;
}

- (void)getTopImagesWithFilter:(PTTopImageFilter)filter numberOfImages:(NSString*)number completion:(CompletionHandler)completionHandler{
    
    NSString *resultFilter = [self topImageFilterTransfer:filter];
    NSDictionary* filterDic = @{@"filter":resultFilter,@"number":number};
    NSData *filterData = [NSJSONSerialization dataWithJSONObject:filterDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *filterString = [[NSString alloc]initWithData:filterData encoding:NSUTF8StringEncoding];
    NSDictionary *filterParamaters = @{@"data":filterString};
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_TOP_IMAGES_URL parameters:filterParamaters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSArray *images;
//        if ([responseObject objectForKey:@"images"]) {
//            images = [responseObject objectForKey:@"images"];
//            completionHandler(nil,images);
//        } else {
//            completionHandler(nil,responseObject);
//        }
        NSLog(@"doGET GetTopImages OK: %@",responseObject);
        completionHandler(nil,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET GetTopImages Error: %@",error);
        completionHandler(error,nil);
    }];
    

}

-(void)getTourInfoWithTourID:(NSString *)tourID completion:(CompletionHandler)completionHandler{
    NSDictionary *getParameter = @{@"tourID":tourID};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_TOURINFO_URL parameters:getParameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doGET get_tourInfo.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET get_tourInfo.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)getImageInfoWithImageID:(NSString *)imageID completion:(CompletionHandler)completionHandler{
    NSDictionary *getParameter = @{@"imageID":imageID};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_IMAGEINFO_URL parameters:getParameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doGET get_imageInfo.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET get_imageInfo.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)getUserInfoWithUserID:(NSString *)userID completion:(CompletionHandler)completionHandler{
    NSDictionary *getParameter = @{@"userID":userID};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_USERINFO_URL parameters:getParameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doGET get_userInfo.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET get_userInfo.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)uploadCommentWithCommentInfo:(NSDictionary *)commentInfo completion:(CompletionHandler)completionHandler{
        NSData *commentInfoData = [NSJSONSerialization dataWithJSONObject:commentInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *commentInfoString = [[NSString alloc]initWithData:commentInfoData encoding:NSUTF8StringEncoding];
    NSDictionary *commentInfoParameters = @{@"data":commentInfoString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:COMMENT_URL parameters:commentInfoParameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST comment.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doPOST comment.php Error: %@",error);
        completionHandler(error,nil);
        
    }];
}

-(void)uploadLikeWithUserID:(NSString *)userID targetID:(NSString *)targetID targetType:(NSString *)targetType completion:(CompletionHandler)completionHandler{
    NSDictionary *getParameter = @{@"user_id":userID,@"target_id":targetID,@"target_type":targetType};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:LIKE_URL parameters:getParameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doGET like.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET like.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)getCommentsWithTargetID:(NSString *)targetID targetType:(NSString *)targetType completion:(CompletionHandler)completionHandler{
    NSDictionary *getParameter = @{@"target_id":targetID,@"target_type":targetType};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_COMMENTS_URL parameters:getParameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doGET get_comments.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET get_comments.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)getLikesWithTargetID:(NSString *)targetID targetType:(NSString *)targetType completion:(CompletionHandler)completionHandler{
    NSDictionary *getParameter = @{@"target_id":targetID,@"target_type":targetType};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_LIKES_URL parameters:getParameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doGET get_likes.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET get_likes.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)checkLikeWithUserID:(NSString *)userID targetID:(NSString *)targetID targetType:(NSString *)targetType completion:(CompletionHandler)completionHandler{
    NSDictionary *getParameter = @{USER_ID_KEY:userID,@"target_id":targetID,@"target_type":targetType};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_LIKES_URL parameters:getParameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doGET check_likes.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET check_likes.php Error: %@",error);
        completionHandler(error,nil);
    }];
}


-(void)getUserIDWithFBID:(NSString *)FBID completion:(CompletionHandler)completionHandler{
    NSDictionary *getParameter = @{@"FBID":FBID};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:GET_USERID_WITH_FBID_URL parameters:getParameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doGET get_userid_by_FBID.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doGET get_userid_by_FBID.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)registerWithFbUserInfo:(NSDictionary *)fbUserInfo profileImage:(NSData *)profileImage completion:(CompletionHandler)completionHandler{
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:fbUserInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *infoString = [[NSString alloc]initWithData:infoData encoding:NSUTF8StringEncoding];
    NSDictionary *infoParamaters = @{@"data":infoString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:FBUSER_REGISTER_URL parameters:infoParamaters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:profileImage name:@"fileToUpload" fileName:[NSString stringWithFormat:@"%@.JPG",fbUserInfo[@"fb_id"]] mimeType:@"image/jpg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST register_as_fbuser.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doPOST register_as_fbuser.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)registerWithUserInfo:(NSDictionary*)userInfo completion:(CompletionHandler)completionHandler{
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *infoString = [[NSString alloc]initWithData:infoData encoding:NSUTF8StringEncoding];
    NSDictionary *infoParamaters = @{@"data":infoString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:REGISTER_URL parameters:infoParamaters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST register.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doPOST register.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(CompletionHandler)completionHandler{
    NSDictionary *loginInfo = @{@"username":username,@"password":password};
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:loginInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *infoString = [[NSString alloc]initWithData:infoData encoding:NSUTF8StringEncoding];
    NSDictionary *infoParamaters = @{@"data":infoString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:LOGIN_URL parameters:infoParamaters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"doPOST login.php OK Result: %@",responseObject);
        completionHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"doPOST login.php Error: %@",error);
        completionHandler(error,nil);
    }];
}

@end
