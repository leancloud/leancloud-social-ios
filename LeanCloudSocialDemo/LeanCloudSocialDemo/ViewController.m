//
//  ViewController.m
//  LeanCloudSocialDemo
//
//  Created by Feng Junwen on 5/22/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "ViewController.h"
#import <LeanCloudSocial/LeanCloudSocial.h>

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
    [LeanCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"failed to get authentication from weibo. error: %@", error.description);
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                if (error) {
                    NSLog(@"failed to login leancloud. error: %@", error.description);
                } else {
                    _weiboSucc = YES;
                    [self performSegueWithIdentifier:@"WeiboResult" sender:sender];
                }
            }];
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
}

- (IBAction)qzoneLogin:(id)sender {
    _qqSucc = NO;
    [LeanCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"failed to get authentication from weibo. error: %@", error.description);
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformQQ block:^(AVUser *user, NSError *error) {
                if (error) {
                    NSLog(@"failed to login leancloud. error: %@", error.description);
                } else {
                    _qqSucc = YES;
                    [self performSegueWithIdentifier:@"QQResult" sender:sender];
                }
            }];
        }
    } toPlatform:AVOSCloudSNSQQ];
}

- (IBAction)weixinLogin:(id)sender {
    _weixinSucc = NO;
    
}

- (IBAction)renrenLogin:(id)sender {
    _renrenSucc = NO;
}

- (IBAction)unwindToMainMenu:(UIStoryboardSegue*)sender
{
}


@end
