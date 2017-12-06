//
//  AVSNSLoginViewController.m
//  AVOSCloudSNS
//
//  Created by Travis on 13-10-21.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import "AVOSCloudSNS.h"
#import "AVSNSLoginViewController.h"
#import "AVOSCloudSNSUtils.h"
#import "AVOSCloudSNS_.h"

static NSString * const AVOS_SNS_BASE_URL=@"cn.avoscloud.com";
static NSString * const AVOS_SNS_BASE_URL2=@"leancloud.cn";
static NSString * const AVOS_SNS_API_VERSION=@"1";

@interface AVSNSLoginViewController()
@property(nonatomic,copy) NSString *redirect_uri;
@property(nonatomic,copy) NSString *appkey;
@property(nonatomic,copy) NSString *appsec;

@property(nonatomic) BOOL hasCode;
@end
@implementation AVSNSLoginViewController

- (void)dealloc
{
    //NSLog(@"AVSNSLoginViewController dealloc");
}

-(void)close:(UIBarButtonItem*)item{
    [self close];
    [AVOSCloudSNS onCancel:self.type];
}

-(void)setType:(AVOSCloudSNSType)type{
    _type=type;
    if (type==0) {
        return;
    }
    NSDictionary *config=[[AVOSCloudSNS ssoConfigs] objectForKey:@(self.type)];
    NSString *appkey=config[@"appkey"];
    
    if (appkey) {
        //用设置的key尝试直接登陆
        self.appkey=appkey;
        self.appsec=config[@"appsec"];
        self.redirect_uri=config[@"redirect_uri"];
    }
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title=@"帐号绑定";
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];
}
-(void)loginToPlatform:(AVOSCloudSNSType)type{
    if (type==0) {
        //打开选择登录界面
        
        NSString *url=[NSString stringWithFormat:@"https://%@/%@",AVOS_SNS_BASE_URL2,@"sns.html"];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        return;
    }
    
    if (self.appkey) {
        [self startWebAuth];
    } else {
        NSString *sub=nil;
        
        switch (type) {
            case AVOSCloudSNSSinaWeibo:
                sub= [NSString stringWithFormat:@"%@/oauth2/goto/weibo?mobile_sns=true", AVOS_SNS_API_VERSION];
                break;
            case AVOSCloudSNSQQ:
                sub= [NSString stringWithFormat:@"%@/oauth2/goto/qq?mobile_sns=true", AVOS_SNS_API_VERSION];
                break;
                
            default:
                break;
        }
        
        NSString *url=[NSString stringWithFormat:@"https://%@/%@",AVOS_SNS_BASE_URL,sub];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}


-(void)startWebAuth{
    
    switch (self.type) {
        case AVOSCloudSNSSinaWeibo:
        {
            NSDictionary *param=@{
                                  @"client_id":self.appkey,
                                  @"redirect_uri":self.redirect_uri,
                                  @"display":@"mobile",
                                  };
            
            NSURLRequest *req = [[LCSHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:@"https://open.weibo.cn/oauth2/authorize" parameters:param error:nil];
            
            [self.webView loadRequest:req];
        }
            break;
           
            
        case AVOSCloudSNSQQ:
        {
            NSDictionary *params=@{
                                  @"client_id":self.appkey,
                                  @"redirect_uri":self.redirect_uri,
                                  @"display":@"mobile",
                                  @"scope":@"get_simple_userinfo,list_album,upload_pic,do_like",
                                  @"response_type":@"token",
                                  @"which":@"Login",
                                  @"ucheck":@1,
                                  @"fall_to_wv":@1
                                  };
            NSURLRequest *req = [[LCSHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:@"http://openmobile.qq.com/oauth2.0/m_show" parameters:params error:nil];
            
            [self.webView loadRequest:req];
        }
            break;
        case AVOSCloudSNSWeiXin:
            break;
    }
}

-(void)getAccessToken:(NSString*)code{
    
    
    NSString *url=nil;
    NSDictionary *param=nil;
    
    switch (self.type) {
        case AVOSCloudSNSSinaWeibo:
        {
            param=@{
                                  @"client_id":self.appkey,
                                  @"client_secret":self.appsec,
                                  @"redirect_uri":self.redirect_uri,
                                  @"grant_type":@"authorization_code",
                                  @"code":code
                                  };
            
             url=@"https://api.weibo.com/oauth2/access_token";
        }
            break;
           
        case AVOSCloudSNSQQ:
        {
            param=@{
                    @"client_id":self.appkey,
                    @"client_secret":self.appsec,
                    @"redirect_uri":self.redirect_uri,
                    @"grant_type":@"authorization_code",
                    @"code":code
                    };
            
            url=@"https://graph.qq.com/oauth2.0/token";
        }
        default:
            return;
    }
    
    [[AVOSCloudSNS requestManager] POST:url parameters:param success:^(LCSHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *info=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSString *token=info[@"access_token"];
        
        if (token) {
            NSString *uid=info[@"uid"];
            if (uid==nil) {
                uid=info[@"openid"];
            }
            //FIXME: check other uid param if need
            [AVOSCloudSNS onSuccess:self.type withToken:token andExpires:info[@"expires_in"] andUid:uid];
        }else{
            NSError *error=nil;
            //TODO: return unknow error
            [AVOSCloudSNS onFail:self.type withError:error];
        }
    } failure:^(LCSHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *url=[request.URL absoluteString];
    NSLog(@"Open: %@", url);
    NSString *avos_callback_prefix=[NSString stringWithFormat:@"%@/%@/%@",AVOS_SNS_BASE_URL, AVOS_SNS_API_VERSION, @"oauth2/"];
    NSString *avos_callback_prefix2=[NSString stringWithFormat:@"%@/%@/%@",AVOS_SNS_BASE_URL2, AVOS_SNS_API_VERSION, @"oauth2/"];
    
    if ([url rangeOfString:avos_callback_prefix].length>0||[url rangeOfString:avos_callback_prefix2].length>0) {
        //avos 认证, 加载页面JSON
        
        NSRegularExpression *reg=[NSRegularExpression regularExpressionWithPattern:@"[&|\?]code=" options:NSRegularExpressionCaseInsensitive error:nil];
        
        BOOL hasCode= [reg numberOfMatchesInString:url options:0 range:NSMakeRange(0, [url length])];
        
        if(hasCode){
            //avos返回用户信息
            [[AVOSCloudSNS requestManager] GET:url parameters:nil success:^(LCSHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *info=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                info=info[@"user"];
                if (info) {
                    [AVOSCloudSNS onSuccess:self.type withParams:info];
                }else{
                    NSLog(@"avos server format error");
                    NSError *err=[NSError errorWithDomain:AVOSCloudSNSErrorDomain code:9999 userInfo:info];
                    [AVOSCloudSNS onFail:self.type withError:err];
                }
            } failure:^(LCSHTTPRequestOperation *operation, NSError *error) {
                [AVOSCloudSNS onFail:self.type withError:error];
            }];
            return NO;
        }else if ([url rangeOfString:@"access_denied"].length>0) {
            //用户取消
            [AVOSCloudSNS onFail:self.type withError:[NSError errorWithDomain:AVOSCloudSNSErrorDomain code:AVOSCloudSNSErrorUserCancel userInfo:nil]];
            return NO;
        }else if(self.type==0){
            //获取用户选择的登录平台
            if ([url rangeOfString:@"goto/weibo"].length) {
                self.type=AVOSCloudSNSSinaWeibo;
            }else if ([url rangeOfString:@"goto/qq"].length) {
                self.type=AVOSCloudSNSQQ;
            }else if ([url rangeOfString:@"goto/"].length) {
                NSAssert(NO, @"SDK not support this platform!");
            }
            
            if (self.appkey) {
                //检查是否SSO登录
                if ([AVOSCloudSNS SSO:self.type])
                    return NO;
                
                //web认证
                [self performSelector:@selector(startWebAuth) withObject:nil afterDelay:0.1];
                
                return NO;
            }
        }
        
    }else if(self.redirect_uri && [url hasPrefix:self.redirect_uri]){
        NSDictionary *param= [AVOSCloudSNSUtils unserializeURL:url];
        NSString *code=param[@"code"];
        NSString *token=param[@"access_token"];
        if (code) {
            [self getAccessToken:code];
            return NO;
        }else if (token && self.type==AVOSCloudSNSQQ){
            [[AVOSCloudSNS requestManager] GET:[NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/me?access_token=%@",token] parameters:nil success:^(LCSHTTPRequestOperation *operation, id responseObject) {
                NSString *string=[[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:NSUTF8StringEncoding];
                NSDictionary *ret= [AVOSCloudSNSUtils unserializeJSONP:string];
                NSString *openid=ret[@"openid"];
                [AVOSCloudSNS onSuccess:self.type withToken:token andExpires:param[@"expires_in"] andUid:openid];
            } failure:^(LCSHTTPRequestOperation *operation, NSError *error) {
                [AVOSCloudSNS onFail:AVOSCloudSNSQQ withError:error];
            }];
        }
    }else{
//        NSLog(@"Open :%@",url);
    }
    
    return YES;
}

-(void)showWait{
    UIActivityIndicatorView *view=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [view startAnimating];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:view];
}

-(void)hideWait{
    self.navigationItem.rightBarButtonItem=nil;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self hideWait];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self showWait];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    if ((error.code==101 || error.code == 102) && [error.domain isEqualToString:@"WebKitErrorDomain"]) {
        //ignore
    }else{
        [self hideWait];
        [AVOSCloudSNS onFail:self.type withError:error];
    }
    
}

@end
