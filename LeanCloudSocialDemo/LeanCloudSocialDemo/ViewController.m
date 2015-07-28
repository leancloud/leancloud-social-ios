//
//  ViewController.m
//  LeanCloudSocialDemo
//
//  Created by Feng Junwen on 5/22/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "ViewController.h"
#import "AVOSCloudSNS.h"

@interface ViewController () {
    BOOL _weiboSucc;
    BOOL _qqSucc;
    BOOL _weixinSucc;
    BOOL _renrenSucc;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _weiboSucc = NO;
    _qqSucc = NO;
    _weixinSucc = NO;
    _renrenSucc = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return NO;
}

- (IBAction)weiboLogin:(id)sender {
    _weiboSucc = NO;
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"failed to get authentication from weibo. error: %@", error.description);
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                if (error) {
                    NSLog(@"failed to login leancloud. error: %@", error.description);
                } else {
                    _weiboSucc = YES;
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"登录成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                    [self performSegueWithIdentifier:@"WeiboResult" sender:sender];
                }
            }];
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
}

- (IBAction)weiboLogin2:(id)sender {
    //此处的 URL 从网站管理台获取，组件->社交
    [AVOSCloudSNS loginWithURL:[NSURL URLWithString:@"https://leancloud.cn/1.1/sns/goto/vdhgf2lq96udqd73"] callback:^(id object, NSError *error) {
        NSLog(@"object : %@, error : %@", object, error);
        if ([self filerError:error]) {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                if ([self filerError:error]) {
                    [self alert:@"登录成功"];
                    NSLog(@"user : %@", user);
                }
            }];
        }
    }];
}

- (IBAction)qzoneLogin:(id)sender {
    _qqSucc = NO;
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"failed to get authentication from weibo. error: %@", error.description);
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformQQ block:^(AVUser *user, NSError *error) {
                if (error) {
                    NSLog(@"failed to login leancloud. error: %@", error.description);
                } else {
                    _qqSucc = YES;
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"登录成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                    [self performSegueWithIdentifier:@"QQResult" sender:sender];
                }
            }];
        }
    } toPlatform:AVOSCloudSNSQQ];
}

- (IBAction)qzoneLogin2:(id)sender {
    [AVOSCloudSNS loginWithURL:[NSURL URLWithString:@"https://leancloud.cn/1.1/sns/goto/36wvmahsj3davi90"] callback:^(id object, NSError *error) {
        NSLog(@"object : %@ error: %@", object, error);
    }];
}

- (IBAction)weixinLogin:(id)sender {
    _weixinSucc = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意" message:@"本 Demo 尚未实现微信账号登录，请你自己申请微信开放平台账号，并导入。" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)renrenLogin:(id)sender {
    _renrenSucc = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意" message:@"本 Demo 尚未实现人人账号登录，请你自己申请人人网开放平台账号，并导入。" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)wechatLogin:(id)sender {
    [AVOSCloudSNS loginWithURL:[NSURL URLWithString:@"https://leancloud.cn/1.1/sns/goto/1t261wmvqzthpx0y"] callback:^(id object, NSError *error) {
        NSLog(@"object : %@ error: %@", object, error);
    }];
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


@end
