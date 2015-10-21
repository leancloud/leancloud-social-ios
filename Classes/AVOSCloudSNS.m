//
//  AVOSCloudSNS.m
//  paas
//
//  Created by Travis on 13-10-15.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import "AVOSCloudSNS.h"
#import "AVOSCloudSNSUtils.h"
#import "AVSNSLoginViewController.h"

#import <AFNetworking/AFNetworking.h>
#import "AVSNSWebViewController.h"

NSString * const AVOSCloudSNSErrorDomain = @"com.avoscloud.snslogin";

@interface AVOSCloudSNS()

@end

@implementation AVOSCloudSNS

+ (AFHTTPRequestOperationManager *)requestManager {
    static AFHTTPRequestOperationManager *requestManager;
    @synchronized (self) {
        requestManager = [AFHTTPRequestOperationManager manager];
        requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return requestManager;
}

+ (AFHTTPRequestOperationManager *)jsonRequestManager {
    static AFHTTPRequestOperationManager *jsonRequestManager;
    @synchronized (self) {
        if (!jsonRequestManager) {
            jsonRequestManager = [AFHTTPRequestOperationManager manager];
            // 避免服务器不规范，没有返回 application/json
            jsonRequestManager.responseSerializer.acceptableContentTypes = [jsonRequestManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        }
    }
    return jsonRequestManager;
}

/**
 *  保存SSO相关配置
 */
+(NSMutableDictionary*)ssoConfigs{
    static NSMutableDictionary *ssoConfigs=nil;
    
    if (ssoConfigs==nil) {
        ssoConfigs=[[NSMutableDictionary alloc] init];
    }
    
    return ssoConfigs;
}

/**
 *  获取用户设置的回调
 */
+(NSArray*)ssoSchemes{
    NSArray *urls=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (urls.count>0) {
        NSArray *schemes=[urls valueForKeyPath:@"@distinctUnionOfArrays.CFBundleURLSchemes"];
        return schemes;
    }
    return nil;
}


/**
 *  获取 SSO Scheme, 没有设置或设置错误返回nil
 */
+(NSString*)getSSOSchemeWithPlatform:(AVOSCloudSNSType)type{
    NSDictionary *config=[[self ssoConfigs] objectForKey:@(type)];
    NSString *appkey=config[@"appkey"];
    
    if (appkey) {
        NSString *rightOne=nil;
        
        switch (type) {
            case AVOSCloudSNSSinaWeibo:
                rightOne = [NSString stringWithFormat:@"sinaweibosso.%@", appkey];
                break;
             
            case AVOSCloudSNSQQ:
                rightOne = [NSString stringWithFormat:@"tencent%@", appkey];
                break;
                
            case AVOSCloudSNSWeiXin:
                rightOne = appkey;
                break;
                
            default:
                return nil;
                break;
        }
        
        
        //判断是否App已经配置好回调URL
        
        NSArray *schemes=[self ssoSchemes];
        
        for (NSString *scheme in schemes) {
            if ([scheme isEqualToString:rightOne]) {
                return scheme;
            }
        }
    }
    
    NSLog(@"无法使用SSO回调 打开网页模式");
    return nil;
}

/**
 *  尝试SSO登录
 *
 *  @return 是否能用SSO登录
 */
+(BOOL)sinaWeiboSSO{
    BOOL ssoLoggingIn=NO;
  
    NSDictionary *config=[[self ssoConfigs] objectForKey:@(AVOSCloudSNSSinaWeibo)];
    
    //无SSO配置直接返回
    if (config==nil) return NO;
    
    //无回调地址直接返回
    NSString *callback_uri=[self getSSOSchemeWithPlatform:AVOSCloudSNSSinaWeibo];
    if (callback_uri==nil) return NO;
    
    //用打开客户端
    NSString *appAuthBaseURL= [NSString stringWithFormat:@"%@login", [self getWeiboSSOPrefix]];
    
    NSString *red_uri=config[@"redirect_uri"];
    if (red_uri==nil) {
        red_uri=@"http://";
    }
    
    NSString *appAuthURL = [AVOSCloudSNSUtils serializeURL:appAuthBaseURL
                                               params:@{
                                                        @"client_id":config[@"appkey"],
                                                        @"redirect_uri":red_uri,
                                                        @"callback_uri":[callback_uri stringByAppendingString:@"://"],
                                                        }];
    ssoLoggingIn = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appAuthURL]];
    
    return ssoLoggingIn;
}

+(BOOL)qqSSO{
    BOOL ssoLoggingIn=NO;
    
    NSDictionary *config=[[self ssoConfigs] objectForKey:@(AVOSCloudSNSQQ)];
    
    //无SSO配置直接返回
    if (config==nil) return NO;
    
    //无回调地址直接返回
    NSString *callback_uri=[self getSSOSchemeWithPlatform:AVOSCloudSNSQQ];
    if (callback_uri==nil) return NO;
    
    
    
    //QQ的参数是放在系统粘贴板上的
    //@"get_user_info,get_simple_userinfo,add_album,add_idol,add_one_blog,add_pic_t,add_share,add_topic,check_page_fans,del_idol,del_t,get_fanslist,get_idollist,get_info,get_other_info,get_repost_list,list_album,upload_pic";
    
    NSString *scope=@"get_simple_userinfo,add_share";
    
    NSString *appid=config[@"appkey"];
    
    NSDictionary *bld=[[NSBundle mainBundle] infoDictionary];
    NSString *bundleId= [bld objectForKey:(NSString*)kCFBundleIdentifierKey];
    NSString *appName= [bld objectForKey:(NSString*)kCFBundleNameKey];
    
    UIDevice *device=[UIDevice currentDevice];
    
    NSDictionary *dict=@{
                         @"app_id" : appid,
                         @"client_id": appid,
                         @"app_name" : appName,
                         @"bundleId" : bundleId,
                         @"status_machine" : [device model],
                         @"status_os" : [device systemVersion],
                         @"status_version" : [[device systemVersion] substringToIndex:1],
                         @"scope":scope,
                         
                         //目前这些不需要变 我们将来可能要看qq新的sdk的变化
                         @"response_type":@"token",
                         @"sdkp" : @"i",
                         @"sdkv" : @"2.0",
                         @"jsVersion":@"20080",
                         };
    
    NSString *pbType=[@"com.tencent." stringByAppendingString:appid];
    
    [[UIPasteboard generalPasteboard] setValue:[NSKeyedArchiver archivedDataWithRootObject:dict]
                             forPasteboardType:pbType];
    
    NSString *appAuthURL =[NSString stringWithFormat:@"mqqOpensdkSSoLogin://SSoLogin/%@/%@?generalpastboard=1",callback_uri,pbType];
    ssoLoggingIn = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appAuthURL]];
    
    return ssoLoggingIn;
}

+ (BOOL)isConfigCorrectWithType:(AVOSCloudSNSType)type {
    NSDictionary *config=[[self ssoConfigs] objectForKey:@(type)];
    
    //无SSO配置直接返回
    if (config==nil) return NO;
    
    //无回调地址直接返回
    NSString *callback_uri=[self getSSOSchemeWithPlatform:type];
    if (callback_uri==nil) return NO;
    
    return YES;
}

+ (BOOL)weixinSSO {
    BOOL ssoLoggingIn=NO;
    if ([self isConfigCorrectWithType:AVOSCloudSNSWeiXin] == NO) {
        return NO;
    }
    NSDictionary *config=[[self ssoConfigs] objectForKey:@(AVOSCloudSNSWeiXin)];
    // ipad 不一样？
    NSString *baseAuthUrl = [NSString stringWithFormat:@"weixin://app/%@/auth/", config[@"appkey"]];
    NSString *appAuthUrl = [AVOSCloudSNSUtils serializeURL:baseAuthUrl params:@{@"scope":@"snsapi_userinfo", @"state": @"Weixinauth"}];
    ssoLoggingIn = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appAuthUrl]];
    return ssoLoggingIn;
}

+(BOOL)SSO:(AVOSCloudSNSType)type{
    switch (type) {
        case AVOSCloudSNSSinaWeibo:
            return [AVOSCloudSNS sinaWeiboSSO];
            break;
            
        case AVOSCloudSNSQQ:
            return [AVOSCloudSNS qqSSO];
            break;
            
        case AVOSCloudSNSWeiXin:
            return [AVOSCloudSNS weixinSSO];
            
    }
    return NO;
}

+(BOOL)canOpen:(NSString*)url{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

+ (NSString *)getWeiboSSOPrefix {
    NSString *prefix;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        // 用iPad微博打开
        prefix = @"sinaweibohdsso://";
    }else{
        //用iPhone微博打开
        prefix = @"sinaweibosso://";
    }
    return prefix;
}

+ (BOOL)isAppInstalledForType:(AVOSCloudSNSType)type {
    NSString *prefix;
    switch (type) {
        case AVOSCloudSNSQQ:
            prefix = @"mqqOpensdkSSoLogin://";
            break;
        case AVOSCloudSNSSinaWeibo:
            prefix = [self getWeiboSSOPrefix];
            break;
        case AVOSCloudSNSWeiXin:
            prefix = @"weixin://";
            break;
        default:
            break;
    }
    if (prefix) {
        return [self canOpen:prefix];
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark UserInfo Methods

+(NSString*)userFilePath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:@"Preferences/com.avoscloud.snsuser.bin"];
    return path;
}

+(NSMutableDictionary *)loginUsers{
    static NSMutableDictionary *_loginUsers=nil;
    if (_loginUsers==nil) {
        _loginUsers=[[NSKeyedUnarchiver unarchiveObjectWithFile:[self userFilePath]] mutableCopy];
        if (_loginUsers==nil) {
            _loginUsers=[[NSMutableDictionary alloc] initWithCapacity:5];
        }
        
    }
    return _loginUsers;
}

+(NSDictionary*)saveUserInfo:(NSDictionary*)user ofPlatform:(AVOSCloudSNSType)type{
    NSMutableDictionary *tuser=[NSMutableDictionary dictionaryWithDictionary:user];
    [tuser setObject:@(type) forKey:@"platform"];
    
    @try {
        NSString *avatar=nil;
        switch (type) {
            case AVOSCloudSNSSinaWeibo:
                avatar=[user valueForKeyPath:@"raw-user.avatar_large"];
                break;
            case AVOSCloudSNSQQ:
                avatar=[user valueForKeyPath:@"raw-user.figureurl_qq_2"];
                break;
            case AVOSCloudSNSWeiXin:
                avatar=[user valueForKeyPath:@"raw-user.headimgurl"];
                break;
            default:
                break;
        }
        if (avatar) {
            [tuser setObject:avatar forKey:@"avatar"];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"can't get avatar:%@",[exception description]);
    }
    
    [tuser setObject:[tuser valueForKeyPath:@"access-token.access-token"] forKey:@"access_token"];
    
    NSInteger offset=[[tuser valueForKeyPath:@"access-token.expires-in"] integerValue];
    
    NSDate *expireDate=[AVOSCloudSNSUtils expireDateWithOffset:offset];
    [tuser setObject:expireDate forKey:@"expires_at"];
    
    [tuser removeObjectForKey:@"access-token"];
    [tuser removeObjectForKey:@"email"];
    
    [[self loginUsers] setObject:tuser forKey:@(type)];
    [NSKeyedArchiver archiveRootObject:[self loginUsers] toFile:[self userFilePath]];
    return tuser;
}

+(void)deleteUserInfoOfPlatform:(AVOSCloudSNSType)type{
    [[self loginUsers] removeObjectForKey:@(type)];
    [NSKeyedArchiver archiveRootObject:[self loginUsers] toFile:[self userFilePath]];
}

+(BOOL)doesUserExpireOfPlatform:(AVOSCloudSNSType)type{
    //判断过期
    NSDate *expireDate=[[self userInfo:type] objectForKey:@"expires_at"];

    if (!expireDate || [expireDate timeIntervalSinceNow]<120) {
        return YES;
    }
    
    return NO;
}

+(void)refreshToken:(AVOSCloudSNSType)type withCallback:(AVSNSResultBlock)callback{
    //NSAssert(type==AVOSCloudSNSSinaWeibo, @"目前只支持新浪微博");
    
    
    //《access_token自动延续方案》
    //如果用户在授权有效期内重新打开授权页授权（如果此时用户有微博登录状态，这个页面将一闪而过），
    //那么新浪会为开发者自动延长access_token的生命周期，请开发者维护新授权后得access_token值。
    //这个会自动触发，不需要配置什么自动延续的参数~~~
    
    __block UIViewController *vc=nil;
    
    vc=[self loginManualyWithCallback:^(id object, NSError *error) {
        if (error) {
            NSError *err=[NSError errorWithDomain:AVOSCloudSNSErrorDomain code:AVOSCloudSNSErrorTokenExpired userInfo:error.userInfo];
            callback(object,err);
        }else if (object){
            callback(object,error);
        }
        vc=nil;
    } toPlatform:type];
    
    
}

#pragma mark -
#pragma mark Callback Methods
+(void)onSuccess:(AVOSCloudSNSType)type withToken:(NSString*)token andExpires:(NSString*)expires andUid:(NSString*)uid{
    
    NSString *url=nil;
    NSDictionary *params=nil;
    switch (type) {
            
        case AVOSCloudSNSSinaWeibo: {
            url=@"https://api.weibo.com/2/users/show.json";
            params=@{
                     @"access_token":token,
                     @"uid":uid
                     };
            break;
        }
        case AVOSCloudSNSQQ:
        {
            NSDictionary *config=[[self ssoConfigs] objectForKey:@(type)];
            params=@{@"format":@"json",
                @"access_token":token,
                @"oauth_consumer_key":config[@"appkey"],
                @"openid":uid};
            url=@"https://openmobile.qq.com/user/get_simple_userinfo";
        }
            break;
        case AVOSCloudSNSWeiXin: {
            params = @{@"access_token":token, @"openid":uid};
            url = @"https://api.weixin.qq.com/sns/userinfo";
            break;
        }
        default:
            NSAssert(NO, @"不支持的平台类型");
            break;
    }
    [[self requestManager] GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *params= [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSString *error=params[@"error"];
        if (error) {
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:params];
            [dict setObject:error forKey:NSLocalizedFailureReasonErrorKey];
            NSError *err=[NSError errorWithDomain:AVOSCloudSNSErrorDomain code:AVOSCloudSNSErrorLoginFail userInfo:dict];
            [AVOSCloudSNS onFail:type withError:err];
        }else{
            NSMutableDictionary *dict=[NSMutableDictionary dictionary];
            [dict setObject:@{@"access-token":token,@"expires-in":@([expires integerValue])} forKey:@"access-token"];
            
            [dict setObject:uid forKey:@"id"];
            switch (type) {
                case AVOSCloudSNSSinaWeibo:
                    [dict setObject:[params objectForKey:@"name"] forKey:@"username"];
                    break;
                case AVOSCloudSNSQQ:
                    [dict setObject:[params objectForKey:@"nickname"] forKey:@"username"];
                    break;
                case AVOSCloudSNSWeiXin:
                    [dict setObject:[params objectForKey:@"nickname"] forKey:@"username"];
                    break;
                default:
                    break;
            }
            
            
            [dict setObject:params forKey:@"raw-user"];
            
            [AVOSCloudSNS onSuccess:type withParams:dict];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AVOSCloudSNS onFail:type withError:error];
    }];
}

+(void)onSuccess:(AVOSCloudSNSType)type withParams:(NSDictionary*)info{
    //保存用户信息
    info= [self saveUserInfo:info ofPlatform:type];
    
    __block AVSNSLoginViewController *vc= [[self ssoConfigs] objectForKey:@"tmpvc"];
    [[self ssoConfigs] removeObjectForKey:@"tmpvc"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc close];
        AVSNSResultBlock callback=(AVSNSResultBlock) [[self ssoConfigs] objectForKey:@"callback"];
        if(callback){
            callback(info,nil);
            [[self ssoConfigs] removeObjectForKey:@"callback"];
        }
        
        vc=nil;
        
    });
}

+(void)onFail:(AVOSCloudSNSType)type withError:(NSError*)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        AVSNSLoginViewController *vc= [[self ssoConfigs] objectForKey:@"tmpvc"];
        [vc close];
        [[self ssoConfigs] removeObjectForKey:@"tmpvc"];
        
        AVSNSResultBlock callback=(AVSNSResultBlock) [[self ssoConfigs] objectForKey:@"callback"];
        if(callback){
            callback(nil,error);
            [[self ssoConfigs] removeObjectForKey:@"callback"];
        }
    });
}

+(void)onCancel:(AVOSCloudSNSType)type{
    NSError *error=[NSError errorWithDomain:AVOSCloudSNSErrorDomain code:AVOSCloudSNSErrorUserCancel userInfo:nil];
    [self onFail:type withError:error];
}

#pragma mark -
#pragma mark Public Methods

+(void)logout:(AVOSCloudSNSType)type{
    
    //revoke the access token
    switch (type) {
        case AVOSCloudSNSSinaWeibo:
        {
            NSDictionary *dict= [AVOSCloudSNS userInfo:AVOSCloudSNSSinaWeibo];
            if (dict) {
                NSString *token=[dict objectForKey:@"access_token"];

                [[self requestManager] GET:@"https://api.weibo.com/oauth2/revokeoauth2" parameters:@{@"access_token":token} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                }];
            }
        }
            break;
            
        default:
            break;
    }
    
    
    [self deleteUserInfoOfPlatform:type];
    
    
}

+(NSDictionary*)userInfo:(AVOSCloudSNSType)type{
    return [[self loginUsers] objectForKey:@(type)];
}

+(BOOL)handleOpenURL:(NSURL *)url{
    NSString *scheme=url.scheme;
    
    NSDictionary *params=[AVOSCloudSNSUtils unserializeURL:[url absoluteString]];
    NSLog(@"Params: %@",[params description]);
    if ([scheme hasPrefix:@"sinaweibosso"]) {
        
        NSString *token=params[@"access_token"];
        NSString *expires=params[@"expires_in"];
        NSString *uid=params[@"uid"];
        if (token) {
            [self onSuccess:AVOSCloudSNSSinaWeibo withToken:token andExpires:expires andUid:uid];
        }else{
            //登录失败 SSO只有用户取消一种可能
            [self onCancel:AVOSCloudSNSSinaWeibo];
        }
    }else if ([scheme hasPrefix:@"tencent"]) {

        if ([[params objectForKey:@"generalpastboard"] isEqualToString:@"1"]) {
            NSString *pbname=[NSString stringWithFormat:@"com.tencent.%@",scheme];
            
            UIPasteboard *pb=[UIPasteboard generalPasteboard];
            id value=[pb valueForPasteboardType:pbname];
            params= [NSKeyedUnarchiver unarchiveObjectWithData:value];
            [UIPasteboard removePasteboardWithName:pbname];
            
            if (params && [params isKindOfClass:[NSDictionary class]]) {
                NSString *token=params[@"access_token"];
                NSString *expires=params[@"expires_in"];
                NSString *uid=params[@"openid"];
                
                
                if (token) {
                    [self onSuccess:AVOSCloudSNSQQ withToken:token andExpires:expires andUid:uid];
                }else{
                    if ([params[@"user_cancelled"] isEqualToString:@"YES"]) {
                        //登录失败 SSO只有用户取消一种可能
                        [self onCancel:AVOSCloudSNSQQ];
                    }else{
                        [self onFail:AVOSCloudSNSQQ withError:[NSError errorWithDomain:AVOSCloudSNSErrorDomain code:3 userInfo:params]];
                    }
                }
            }
        }
    }else if ([scheme hasPrefix:@"wx"]){
        if (params) {
            NSLog(@"wexin : %@", params);
            NSString *code = params[@"code"];
            if (code) {
                // success
                [self getWeixinAccessTokenByCode:code block:^(id object, NSError *error) {
                    if (error) {
                        [self onFail:AVOSCloudSNSWeiXin withError:error];
                    } else {
                        NSString *openId = [object objectForKey:@"openid"];
                        NSString *expires = [object objectForKey:@"expires_in"];
                        NSString *accessToken = [object objectForKey:@"access_token"];
                        [self onSuccess:AVOSCloudSNSWeiXin withToken:accessToken andExpires:expires andUid:openId];
                    }
                }];
            }
        } else {
            //用户取消授权 ?
            [self onFail:AVOSCloudSNSWeiXin withError:[self errorWithCode:AVOSCloudSNSErrorUserCancel text:@"用户取消了授权"]];
        }
    } else {
        return NO;
    }
    return YES;
}

+ (NSError *)errorWithCode:(NSInteger)code text:(NSString *)text {
    return [NSError errorWithDomain:AVOSCloudSNSErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:text}];
}

+ (void)getWeixinAccessTokenByCode:(NSString *)code block:(AVSNSResultBlock)block{
    NSDictionary *config = [[self ssoConfigs] objectForKey:@(AVOSCloudSNSWeiXin)];
    NSString *appId = config[@"appkey"];
    NSString *secret = config[@"appsec"];
    NSDictionary *params = @{@"appid":appId, @"secret": secret, @"code":code, @"grant_type":@"authorization_code"};
    AFHTTPRequestOperationManager *manager = [self jsonRequestManager];
    [manager GET:@"https://api.weixin.qq.com/sns/oauth2/access_token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"access_token"]) {
            block(responseObject, nil);
        } else {
            // weixin system error
            block(nil, [NSError errorWithDomain:AVOSCloudSNSErrorDomain code:AVOSCloudSNSErrorLoginFail userInfo:@{NSLocalizedDescriptionKey: [responseObject objectForKey:@"errmsg"]}]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    }];
}

+(void)setupPlatform:(AVOSCloudSNSType)type
          withAppKey:(NSString*)appkey andAppSecret:(NSString*)appsec andRedirectURI:(NSString*)redirect_uri{
    
    NSParameterAssert(appkey);
    NSParameterAssert(appsec);
    
    if ([redirect_uri length]==0) {
        switch (type) {
            case AVOSCloudSNSQQ:
                //redirect_uri=@"http://open.z.qq.com/moc2/success.jsp";
                //FIXME: 通过抓取其它服务的包，发现这样是可以work的
                redirect_uri=@"auth://tauth.qq.com/";
                break;
                
            default:
            case AVOSCloudSNSSinaWeibo:
                NSParameterAssert(redirect_uri);
            
                break;
            case AVOSCloudSNSWeiXin:
                //FIXME:
                redirect_uri = @"";
                break;
        }
        
    }
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setObject:appkey forKey:@"appkey"];
    [dict setObject:appsec forKey:@"appsec"];
    [dict setObject:redirect_uri forKey:@"redirect_uri"];
    [[self ssoConfigs] setObject:dict forKey:@(type)];
}


+(UIViewController*)loginManualyWithCallback:(AVSNSResultBlock)callback{
    if(callback)[[self ssoConfigs] setObject:[callback copy] forKey:@"callback"];
    AVSNSLoginViewController *vc=[[AVSNSLoginViewController alloc] init];
    [vc loginToPlatform:0];
    return vc;
}

+(UIViewController*)loginManualyWithCallback:(AVSNSResultBlock)callback toPlatform:(AVOSCloudSNSType)type{
    if (![self doesUserExpireOfPlatform:type]) {
        //有可用用户数据直接返回
        if(callback)callback([self userInfo:type],nil);
        return nil;
    }
    
    
    if(callback)[[self ssoConfigs] setObject:[callback copy] forKey:@"callback"];
    
    //检查是否SSO登录
    if ([self SSO:type]) return nil;
    
    if (type == AVOSCloudSNSWeiXin) {
        callback(nil, [NSError errorWithDomain:AVOSCloudSNSErrorDomain code:AVOSCloudSNSErrorCodeNotSupported userInfo:@{NSLocalizedDescriptionKey:@"操作不支持"}]);
        return nil;
    } else {
        //网页登录
        AVSNSLoginViewController *vc=[[AVSNSLoginViewController alloc] init];
        vc.type=type;
        [vc loginToPlatform:type];
        return vc;
    }
}

+(UIViewController *)loginManualyWithURL:(NSURL *)url callback:(AVSNSResultBlock)callback {
    AVSNSWebViewController *controller = [[AVSNSWebViewController alloc] init];
    controller.callback = callback;
    [controller.webView loadRequest:[NSURLRequest requestWithURL:url]];
    return controller;
}

+(void)loginWithURL:(NSURL *)url callback:(AVSNSResultBlock)callback {
    UIViewController *controller = [self loginManualyWithURL:url callback:callback];
    [self tryOpenViewController:controller];
}

+(void)loginWithCallback:(AVSNSResultBlock)callback toPlatform:(AVOSCloudSNSType)type{
    UIViewController *vc= [self loginManualyWithCallback:callback toPlatform:type];
    [self tryOpenViewController:vc];
}

+(void)loginWithCallback:(AVSNSResultBlock)callback{
    UIViewController *vc= [self loginManualyWithCallback:callback];
    
    [self tryOpenViewController:vc];
}

+(void)tryOpenViewController:(UIViewController*)vc{
    if (vc) {
        UIViewController *rootC=[[UIApplication sharedApplication].delegate window].rootViewController;
        NSAssert(rootC, @"Can't find rootViewController of the main window! Use 'loginManualyWithCallback'method instead!");
        
        UINavigationController *nvc=[[UINavigationController alloc] initWithRootViewController:vc];
        
        [[self ssoConfigs] setObject:vc forKey:@"tmpvc"];

        if ([rootC isKindOfClass:[UINavigationController class]]) {
            rootC = [(UINavigationController*)rootC visibleViewController];
        }

        [rootC presentViewController:nvc animated:YES completion:nil];
    }
}


+(void)request:(NSURLRequest*)req withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock{
    
    AFHTTPRequestOperation *opt = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    opt.responseSerializer = [AFJSONResponseSerializer serializer];
    [opt setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil,error);
    }];

    if (progressBlock) {
        [opt setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            progressBlock(totalBytesWritten*1.0f/totalBytesExpectedToWrite);
        }];
    }
    
    [opt setQueuePriority:NSOperationQueuePriorityHigh];
    [[NSOperationQueue mainQueue] addOperation:opt];
}


+(void)sinaWeiboShareText:(NSString *)text andImage:(UIImage*)image withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock{
    
    static NSString *updateUrl=@"https://api.weibo.com/2/statuses/%@.json";
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionary];
    NSDictionary *userInfo=[self userInfo:AVOSCloudSNSSinaWeibo];
    [parameters setObject:userInfo[@"access_token"] forKey:@"access_token"];
    [parameters setObject:text forKey:@"status"];
    
    NSString *urlString=nil;
    NSMutableURLRequest *request=nil;
    if (image) {
        urlString=[NSString stringWithFormat:updateUrl,@"upload"];
        NSError *error;
        request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSData *imageData=UIImageJPEGRepresentation(image, 0.8);
            [formData appendPartWithFormData:imageData name:@"pic"];
            [formData appendPartWithFileData:imageData name:@"pic" fileName:@"image" mimeType:@"image/jpeg"];
        } error:&error];
        if (error) {
            callback(nil, error);
            return;
        }
    }else{
        urlString=[NSString stringWithFormat:updateUrl,@"update"];
        NSError *error;
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:&error];
        if (error) {
            callback(nil, error);
            return;
        }
    }
    
    [self request:request withCallback:callback andProgress:progressBlock];
}

+(void)shareText:(NSString*)text andLink:(NSString*)linkUrl toPlatform:(AVOSCloudSNSType)type withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock{
    if (![self doesUserExpireOfPlatform:type]) {
        switch (type) {
            case AVOSCloudSNSSinaWeibo:
            {
                if (linkUrl) {
                    text=[text stringByAppendingFormat:@" %@",linkUrl];
                }
                [self sinaWeiboShareText:text andImage:nil withCallback:callback andProgress:progressBlock];
            }
                break;
                
            default:
                break;
        }
        
    }else{
        [self refreshToken:type withCallback:^(id object, NSError *error) {
            if (error) {
                callback(nil,error);
            }else{
                [self shareText:text andLink:linkUrl toPlatform:type withCallback:callback andProgress:progressBlock];
            }
        }];
    }
}

+(void)shareText:(NSString*)text andLink:(NSString*)linkUrl andImage:(UIImage*)image toPlatform:(AVOSCloudSNSType)type withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock{
    if (![self doesUserExpireOfPlatform:type]) {
        switch (type) {
            case AVOSCloudSNSSinaWeibo:
            {
                if (linkUrl) {
                    text=[text stringByAppendingFormat:@" %@",linkUrl];
                }
                [self sinaWeiboShareText:text andImage:image withCallback:callback andProgress:progressBlock];
            }
                break;
                
            default:
                break;
        }
        
    }else{
        [self refreshToken:type withCallback:^(id object, NSError *error) {
            if (error) {
                callback(nil,error);
            }else{
                [self shareText:text andLink:linkUrl andImage:image toPlatform:type withCallback:callback andProgress:progressBlock];
            }
        }];
    }
    
}

+(void)shareText:(NSString*)text andLink:(NSString*)linkUrl andImages:(NSArray*)images toPlatform:(AVOSCloudSNSType)type withCallback:(AVSNSResultBlock)callback andProgress:(AVSNSProgressBlock)progressBlock{
    
    if (images.count==1) {
        [self shareText:text andLink:linkUrl andImage:images[0] toPlatform:type withCallback:callback andProgress:progressBlock];
        return;
    }else if(images.count==0){
        [self shareText:text andLink:linkUrl andImage:nil toPlatform:type withCallback:callback andProgress:progressBlock];
        return;
    }
    
    //NSAssert1(type==AVOSCloudSNSSinaWeibo, @"%@ 分享多个图片",NameStringOfParam(type));
    //FIXME: 新浪微博需要高级接口权限才能用 所以目前不打算支持
    
}
@end
