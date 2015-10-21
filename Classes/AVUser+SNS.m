//
//  AVUser+SNS.h
//  VZ
//
//  Created by Travis on 13-10-28.
//  Copyright (c) 2013 AVOS. All rights reserved.
//
#import "AVUser+SNS.h"
#import "AVSNSHttpClient.h"
#import "AVOSCloudSNSUtils.h"
#import "AVOSCloudSNS.h"

NSString *const AVOSCloudSNSPlatformWeiBo = @"weibo";
NSString *const AVOSCloudSNSPlatformQQ = @"qq";
NSString *const AVOSCloudSNSPlatformWeiXin = @"weixin";

@implementation AVUser(SNS)

+ (NSString*)nameOfPlatform:(AVOSCloudSNSType)type {
    switch (type) {
        case AVOSCloudSNSQQ: return @"qq";
        case AVOSCloudSNSSinaWeibo: return @"weibo";
        case AVOSCloudSNSWeiXin: return AVOSCloudSNSPlatformWeiXin;
    }
    return nil;
}

- (AVOSCloudSNSType)platformFromName:(NSString *)name {
    if ([name isEqualToString:AVOSCloudSNSPlatformQQ]) {
        return AVOSCloudSNSQQ;
    } else if ([name isEqualToString:AVOSCloudSNSPlatformWeiBo]) {
        return AVOSCloudSNSSinaWeibo;
    } else if ([name isEqualToString:AVOSCloudSNSPlatformWeiXin]) {
        return AVOSCloudSNSWeiXin;
    } else {
        return -1;
    }
}

- (BOOL)isInternalSupportPlatform:(NSString *)platformName {
    return (int)([self platformFromName:platformName]) != -1;
}

+(NSDictionary *)authDataFromSNSResult:(NSDictionary*)authData{
    NSString *idname=nil;
    
    AVOSCloudSNSType type=[authData[@"platform"] intValue];
    switch (type) {
        case AVOSCloudSNSQQ:
            idname=@"openid";
            break;
        case AVOSCloudSNSWeiXin:
            idname = @"openid";
            break;
        case AVOSCloudSNSSinaWeibo:
        default:
            idname=@"uid";
            break;
    }
    
    id expValue=authData[@"expires_at"];
    NSString *exp=[expValue isKindOfClass:[NSDate class]]?[AVOSCloudSNSUtils stringFromDate:expValue]:expValue;
    
    return @{
             idname:authData[@"id"],
             @"access_token":authData[@"access_token"],
             @"expires_at":exp,
             };
}

+(NSDictionary *)authDataFromSNSResult:(NSDictionary*)authData platform:(NSString *)platform error:(NSError **)error {
    if ([authData objectForKey:@"platform"]) {
        NSNumber *platform = [authData objectForKey:@"platform"];
        if ([platform isKindOfClass:[NSNumber class]]) {
            AVOSCloudSNSType type = [platform intValue];
            if (type == AVOSCloudSNSQQ || type == AVOSCloudSNSSinaWeibo
                || type == AVOSCloudSNSWeiXin) {
                return [self authDataFromSNSResult:authData];
            }
        }
    }
    if (!authData || !platform) {
        *error = [NSError errorWithDomain:@"AVOSClouudSNSDomain" code:0 userInfo:@{@"reason":@"authData or platform is nil"}];
        return nil;
    }
    NSArray *needKeys = nil;
    NSMutableString *keysString = nil;
    if ([platform isEqualToString:AVOSCloudSNSPlatformWeiBo]) {
        needKeys = @[@"uid", @"access_token", @"expiration_in"];
    } else if ([platform isEqualToString:AVOSCloudSNSPlatformQQ]) {
        needKeys = @[@"openid", @"access_token", @"expires_in"];
    } else if ([platform isEqualToString:AVOSCloudSNSPlatformWeiXin]) {
        needKeys = @[@"openid", @"access_token", @"expires_in"];
    } else {
        return authData;
    }
    for (NSString *key in needKeys) {
        if (!keysString) {
            keysString = [[NSMutableString alloc] initWithString:key];
        } else {
            [keysString appendFormat:@",%@", key];
        }
    }
    NSArray *keys = [authData allKeys];
    for (NSString *key in needKeys) {
        if (![keys containsObject:key]) {
            *error = [NSError errorWithDomain:@"AVOSClouudSNSDomain" code:0 userInfo:@{@"message":[NSString stringWithFormat:@"authData for platform %@ should have keys %@", platform, keysString],@"reason":[NSString stringWithFormat:@"key %@ not found", key]}];
            return nil;
        }
    }
    return authData;
}

-(void)deleteAuthDataForPlatform:(NSString *)platform block:(AVUserResultBlock)block {
    NSMutableDictionary *dict = [[self objectForKey:@"authData"] mutableCopy];
    [dict removeObjectForKey:platform];
    [self setObject:dict forKey:@"authData"];
    
    if ([self isInternalSupportPlatform:platform]) {
        [AVOSCloudSNS logout:[self platformFromName:platform]];
    }
    if (self.objectId && self.sessionToken) {
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [AVOSCloudSNSUtils callUserResultBlock:block user:self error:error];
        }];
    } else {
        [AVOSCloudSNSUtils callUserResultBlock:block user:self error:nil];
    }
}

+ (NSString *)platformNameFromAuthData:(NSDictionary *)authData {
    NSNumber *platform = [authData objectForKey:@"platform"];
    NSAssert([platform isKindOfClass:[NSNumber class]], @"The authData should have platform number value");
    AVOSCloudSNSType type = [platform intValue];
    NSString *platformName = [[self class] nameOfPlatform:type];
    NSAssert(platformName != nil, @"The platform is not internally supported");
    return platformName;
}

-(void)addAuthData:(NSDictionary*)authData block:(AVUserResultBlock)block{
    [self addAuthData:authData platform:[[self class] platformNameFromAuthData:authData] block:block];
}

-(void)addAuthData:(NSDictionary*)authData platform:(NSString *)platform block:(AVUserResultBlock)block {
    NSError *error = nil;
    NSDictionary *authDataResult = [[self class] authDataFromSNSResult:authData platform:platform error:&error];
    if (error) {
        [AVOSCloudSNSUtils callUserResultBlock:block user:self error:error];
        return;
    }
    
    if (self.objectId && self.sessionToken) {
        //目前API不支持添加 只会覆盖 所以临时会把用户所有的绑定数据同时发一次 (如果服务器准备好, 直接删除下面两行即可)
        NSMutableDictionary *dict = [[self objectForKey:@"authData"] mutableCopy];
        if (!dict) {
            dict = [[NSMutableDictionary alloc] init];
        }
        [dict setObject:authDataResult forKey:platform];
        [self setObject:dict forKey:@"authData"];
        [self saveEventually:^(BOOL succeeded, NSError *error) {
            [AVOSCloudSNSUtils callUserResultBlock:block user:self error:error];
        }];
    }else{
        //这个是新产生的用户, 需要在服务器注册
        NSDictionary *dict=@{@"authData":@{platform:authDataResult}};
        [[AVSNSHttpClient sharedInstance] postObject:@"users" withParameters:dict block:^(id object, NSError *error) {
            if (!error) {
                [self objectFromDictionary:object];
                [self setObject:dict[@"authData"] forKey:@"authData"];
                // todo: fix me!
                // [self.requestManager clear];
                [[self class] changeCurrentUser:self save:YES];
            }
            [AVOSCloudSNSUtils callUserResultBlock:block user:self error:error];
        }];
    }
}

+(void)loginWithAuthData:(NSDictionary*)authData block:(AVUserResultBlock)block {
    [self loginWithAuthData:authData platform:[[self class] platformNameFromAuthData:authData] block:block];
}

+(void)loginWithAuthData:(NSDictionary*)authData platform:(NSString *)platform block:(AVUserResultBlock)block {
    NSError *error = nil;
    NSDictionary *authDataResult = [self authDataFromSNSResult:authData platform:platform error:&error];
    if (error) {
        [AVOSCloudSNSUtils callUserResultBlock:block user:nil error:error];
        return;
    }
    NSDictionary *dict=@{@"authData":@{platform:authDataResult}};
    [[AVSNSHttpClient sharedInstance] postObject:@"users" withParameters:dict block:^(id object, NSError *error) {
        AVUser * user = nil;
        if (!error) {
            if ([object objectForKey:@"objectId"]) {
                // 第一次会返回
                // objectId = 55b8b76400b066e34529d4a6;
                // sessionToken = fzs03y5g7hr4r22iikhv2babe;
                // createdAt = "2015-07-29T11:33:03.642Z";
                // username = mzv62gzwrwzqtz75rv51kzye6;
                
                user = [self user];
                [user objectFromDictionary:object];
                if(!object[@"authData"]){
                    [user setObject:dict[@"authData"] forKey:@"authData"];
                }
                // todo: fix me!
                // [user.requestManager clear];
                [[self class] changeCurrentUser:user save:YES];
            } else {
                // {code = 1;error = "无效的第三方数据";}
                error = [NSError errorWithDomain:AVOSCloudSNSErrorDomain code:AVOSCloudSNSErrorCodeAuthDataError userInfo:@{NSLocalizedFailureReasonErrorKey: object}];
            }
        }
        [AVOSCloudSNSUtils callUserResultBlock:block user:user error:error];
    }];
}
@end
