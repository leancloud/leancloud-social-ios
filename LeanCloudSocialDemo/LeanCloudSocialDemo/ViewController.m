//
//  ViewController.m
//  LeanCloudSocialDemo
//
//  Created by Feng Junwen on 5/22/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "ViewController.h"
#import "AVOSCloudSNS.h"
#import "ResultViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"2548122881" andAppSecret:@"ba37a6eb3018590b0d75da733c4998f8" andRedirectURI:@"http://wanpaiapp.com/oauth/callback/sina"];
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ withAppKey:@"100512940" andAppSecret:@"afbfdff94b95a2fb8fe58a8e24c4ba5f" andRedirectURI:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)weiboLogin:(id)sender {
    // 如果安装了微博，直接跳转到微博应用，否则跳转至网页登录
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"failed to get authentication from weibo. error: %@", error.description);
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                if ([self filerError:error]) {
                    [self loginSucceedWithUser:user authData:object];
                }
            }];
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
}

- (IBAction)weiboWebLogin:(id)sender {
    //此处的 URL 从网站管理台获取，组件->社交，把 AppId 和 Secret Key 写在管理台
    //管理台生成网页url，来跳转至第三方登录的地址
    [AVOSCloudSNS loginWithURL:[NSURL URLWithString:@"https://leancloud.cn/1.1/sns/goto/vdhgf2lq96udqd73"] callback:^(id object, NSError *error) {
        NSLog(@"object : %@, error : %@", object, error);
        if ([self filerError:error]) {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                if ([self filerError:error]) {
                    [self loginSucceedWithUser:user authData:object];
                }
            }];
        }
    }];
}

- (IBAction)qzoneLogin:(id)sender {
    // 如果安装了QQ，则跳转至应用，否则跳转至网页
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"failed to get authentication from weibo. error: %@", error.description);
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformQQ block:^(AVUser *user, NSError *error) {
                if ([self filerError:error]) {
                    [self loginSucceedWithUser:user authData:object];
                }
            }];
        }
    } toPlatform:AVOSCloudSNSQQ];
}

- (IBAction)qzoneLogin2:(id)sender {
    // 这个需要到后台填写 应用 id 和 secret key
    [AVOSCloudSNS loginWithURL:[NSURL URLWithString:@"https://leancloud.cn/1.1/sns/goto/36wvmahsj3davi90"] callback:^(id object, NSError *error) {
        NSLog(@"object : %@ error: %@", object, error);
        if ([self filerError:error]) {
            // clean authData;
            NSMutableDictionary *authData = [NSMutableDictionary dictionary];
            [authData setObject:[object objectForKey:@"openid"] forKey:@"openid"];
            [authData setObject:[object objectForKey:@"expires_in"] forKey:@"expires_in"];
            [authData setObject:[object objectForKey:@"access_token"] forKey:@"access_token"];
            [AVUser loginWithAuthData:authData platform:AVOSCloudSNSPlatformQQ block:^(AVUser *user, NSError *error) {
                if ([self filerError:error]) {
                    [self loginSucceedWithUser:user authData:authData];
                }
            }];
        }
    }];
}

- (IBAction)weixinLogin:(id)sender {
    // 需要自己去下载微信的 sdk，获得 authData，之后用 +[AVUser loginWithAuthData:block] 来登录
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意" message:@"本 Demo 尚未实现微信账号登录，请你自己申请微信开放平台账号，并导入。" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)wechatLogin:(id)sender {
    [AVOSCloudSNS loginWithURL:[NSURL URLWithString:@"https://leancloud.cn/1.1/sns/goto/1t261wmvqzthpx0y"] callback:^(id object, NSError *error) {
        NSLog(@"object : %@ error: %@", object, error);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"goLoginResult"]) {
        ResultViewController *vc = (ResultViewController *)segue.destinationViewController;
        vc.infoText = sender;
    }
}

- (IBAction)unwindToMainMenu:(UIStoryboardSegue*)sender
{
}

- (void)alert:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (BOOL)filerError:(NSError *)error {
    if (error) {
        [self alert:[error localizedDescription]];
        return NO;
    }
    return YES;
}

- (void)loginSucceedWithUser:(AVUser *)user authData:(NSDictionary *)authData{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ResultViewController *vc  = [storyboard instantiateViewControllerWithIdentifier:@"ResultViewControllerID"];
    vc.infoText = [NSString stringWithFormat:@"authData:%@", authData];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
