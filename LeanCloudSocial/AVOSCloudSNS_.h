//
//  AVOSCloudSNS_.h
//  AVOSCloudSNS
//
//  Created by Travis on 13-10-21.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#ifndef AVOSCloudSNS_AVOSCloudSNS__h
#define AVOSCloudSNS_AVOSCloudSNS__h

#import "AVOSCloudSNS.h"
#import <AFNetworking/AFNetworking.h>

@interface AVOSCloudSNS ()
+(NSMutableDictionary*)ssoConfigs;
+ (AFHTTPRequestOperationManager *)requestManager;

+(void)onSuccess:(AVOSCloudSNSType)type withToken:(NSString*)token andExpires:(NSString*)expires andUid:(NSString*)uid;
+(void)onSuccess:(AVOSCloudSNSType)type withParams:(NSDictionary*)info;

+(void)onFail:(AVOSCloudSNSType)type withError:(NSError*)error;

+(void)onCancel:(AVOSCloudSNSType)type;

+(NSMutableDictionary *)loginUsers;
+(NSDictionary*)saveUserInfo:(NSDictionary*)user ofPlatform:(AVOSCloudSNSType)type;
+(void)deleteUserInfoOfPlatform:(AVOSCloudSNSType)type;

+(BOOL)SSO:(AVOSCloudSNSType)type;


+(void)sinaWeiboShareText:(NSString *)text andImage:(UIImage*)image withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock;

+(void)shareText:(NSString*)text andLink:(NSString*)linkUrl andImages:(NSArray*)images toPlatform:(AVOSCloudSNSType)type withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock;
@end

#endif
