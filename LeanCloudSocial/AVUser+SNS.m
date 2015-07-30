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

+(NSString*)nameOfPlatform:(AVOSCloudSNSType)type{
    switch (type) {
        case AVOSCloudSNSQQ: return @"qq";
            
        case AVOSCloudSNSSinaWeibo: return @"weibo";
        case AVOSCloudSNSWeiXin: return AVOSCloudSNSPlatformWeiXin;
    }
    return nil;
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

-(void)deleteAuthForPlatform:(AVOSCloudSNSType)type block:(AVUserResultBlock)block{
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[self objectForKey:@"authData"]];
    [dict removeObjectForKey:[[self class] nameOfPlatform:type]];
    
    [self setObject:dict forKey:@"authData"];
    
    [AVOSCloudSNS logout:type];
    __weak AVUser *ws=self;
    if (self.objectId && self.sessionToken) {
        [self saveEventually:^(BOOL succeeded, NSError *error) {
            if(block)[AVOSCloudSNSUtils callUserResultBlock:block user:ws error:error];
        }];
    }else{
        if(block)[AVOSCloudSNSUtils callUserResultBlock:block user:self error:nil];
    }
}

-(void)deleteAuthDataForPlatform:(NSString *)platform block:(AVUserResultBlock)block {
    NSMutableDictionary *dict = [[self objectForKey:@"authData"] mutableCopy];
    [dict removeObjectForKey:platform];
    if (self.objectId && self.sessionToken) {
        [self saveEventually:^(BOOL succeeded, NSError *error) {
            if(block) {
                [AVOSCloudSNSUtils callUserResultBlock:block user:self error:error];
            }
        }];
    } else {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AVOSCloudSNSUtils callUserResultBlock:block user:self error:nil];
            });
        }
    }
}

-(void)addAuthData:(NSDictionary*)authData block:(AVUserResultBlock)block{
    if (authData) {
        __weak AVUser *ws=self;
        
        if (self.objectId && self.sessionToken) {
            //目前API不支持添加 只会覆盖 所以临时会把用户所有的绑定数据同时发一次 (如果服务器准备好, 直接删除下面两行即可)
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[self objectForKey:@"authData"]];
            [dict setObject:[[self class] authDataFromSNSResult:authData] forKey:[[self class] nameOfPlatform:[authData[@"platform"] intValue]]];
            
            [self setObject:dict forKey:@"authData"];
            
            [self saveEventually:^(BOOL succeeded, NSError *error) {
                if(block)[AVOSCloudSNSUtils callUserResultBlock:block user:ws error:error];
            }];
        }else{
            //这个是新产生的用户, 需要在服务器注册
            NSDictionary *dict=@{@"authData":@{
                                         [[self class] nameOfPlatform:[authData[@"platform"] intValue]]:
                                             [[self class] authDataFromSNSResult:authData]
                                         }};
            [[AVSNSHttpClient sharedInstance] postObject:@"users" withParameters:dict block:^(id object, NSError *error) {
                if (error == nil)
                {
                    [AVOSCloudSNSUtils copyDictionary:object toObject:ws];
                    [ws setObject:dict[@"authData"] forKey:@"authData"];
// todo: fix me!
//                    [ws.requestManager clear];
                    [[self class] changeCurrentUser:ws save:YES];
                }
                
                
                if(block)[AVOSCloudSNSUtils callUserResultBlock:block user:ws error:error];
            }];
        }
        
        
    }
}

-(void)addAuthData:(NSDictionary*)authData platform:(NSString *)platform block:(AVUserResultBlock)block {
    NSError *error = nil;
    NSDictionary *authDataResult = [[self class] authDataFromSNSResult:authData platform:platform error:&error];
    if (error) {
        if(block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AVOSCloudSNSUtils callUserResultBlock:block user:self error:error];
            });
        }
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
            if(block) {
                [AVOSCloudSNSUtils callUserResultBlock:block user:self error:error];
            }
        }];
    }else{
        //这个是新产生的用户, 需要在服务器注册
        NSDictionary *dict=@{@"authData":@{platform:authDataResult}};
        [[AVSNSHttpClient sharedInstance] postObject:@"users" withParameters:dict block:^(id object, NSError *error) {
            if (!error) {
                [AVOSCloudSNSUtils copyDictionary:object toObject:self];
                [self setObject:dict[@"authData"] forKey:@"authData"];
// todo: fix me!
//                    [self.requestManager clear];
                [[self class] changeCurrentUser:self save:YES];
            }
            if(block) {
                [AVOSCloudSNSUtils callUserResultBlock:block user:self error:error];
            }
        }];
    }
}

+(void)loginWithAuthData:(NSDictionary*)authData
                   block:(AVUserResultBlock)block{
    
    
    
    NSDictionary *dict=@{@"authData":@{
                                 [self nameOfPlatform:[authData[@"platform"] intValue]]:
                                     [self authDataFromSNSResult:authData]
                                 }};
    
    
    [[AVSNSHttpClient sharedInstance] postObject:@"users" withParameters:dict block:^(id object, NSError *error) {
        
        AVUser * user = nil;
        if (error == nil)
        {
            user = [[self class] user];
            [AVOSCloudSNSUtils copyDictionary:object toObject:user];
            
            if(object[@"authData"]==nil){
                [user setObject:dict[@"authData"] forKey:@"authData"];
            }
            
// todo: fix me!
//                [user.requestManager clear];
            [[self class] changeCurrentUser:user save:YES];
        }
        
        
        if(block)[AVOSCloudSNSUtils callUserResultBlock:block user:user error:error];
    }];
}

+(void)loginWithAuthData:(NSDictionary*)authData platform:(NSString *)platform block:(AVUserResultBlock)block {
    NSError *error = nil;
    NSDictionary *authDataResult = [self authDataFromSNSResult:authData platform:platform error:&error];
    if (error) {
        if(block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AVOSCloudSNSUtils callUserResultBlock:block user:nil error:error];
            });
        }
        return;
    }
    NSDictionary *dict=@{@"authData":@{platform:authDataResult}};
    [[AVSNSHttpClient sharedInstance] postObject:@"users" withParameters:dict block:^(id object, NSError *error) {
        AVUser * user = nil;
        if (!error) {
            if ([object objectForKey:@"objectId"]) {
                //            第一次会返回
                //            objectId = 55b8b76400b066e34529d4a6;
                //            sessionToken = fzs03y5g7hr4r22iikhv2babe;
                //            createdAt = "2015-07-29T11:33:03.642Z";
                //            username = mzv62gzwrwzqtz75rv51kzye6;
                
                user = [self user];
                [user objectFromDictionary:object];
                if(!object[@"authData"]){
                    [user setObject:dict[@"authData"] forKey:@"authData"];
                }
                // todo: fix me!
                //            [user.requestManager clear];
                [[self class] changeCurrentUser:user save:YES];
            } else {
//                {code = 1;error = "无效的第三方数据";}
                error = [NSError errorWithDomain:AVOSCloudSNSErrorDomain code:AVOSCloudSNSErrorCodeAuthDataError userInfo:@{NSLocalizedFailureReasonErrorKey: object}];
            }
        }
        if(block) {
            [AVOSCloudSNSUtils callUserResultBlock:block user:user error:error];
        }
    }];
}
@end
