//
//  ViewController.m
//  LeanCloudSocialDemo
//
//  Created by Feng Junwen on 5/22/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "ViewController.h"
#import "AVOSCloudSocial.h"

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

- (IBAction)unwindToMainMenu:(UIStoryboardSegue*)sender
{
}


@end
