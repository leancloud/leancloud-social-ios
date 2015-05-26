//
//  ViewController.m
//  LeanCloudSocialDemo
//
//  Created by Feng Junwen on 5/22/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "ViewController.h"
#import <LeanCloudSocial/LeanCloudSocial.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)weiboLogin:(id)sender {
    [LeanCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"failed to get authentication from weibo. error: %@", error.description);
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                if (error) {
                    NSLog(@"failed to login leancloud. error: %@", error.description);
                } else {
                    ;
                }
            }];
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
}

- (IBAction)qzoneLogin:(id)sender {
    [LeanCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"failed to get authentication from weibo. error: %@", error.description);
        } else {
            [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformQQ block:^(AVUser *user, NSError *error) {
                if (error) {
                    NSLog(@"failed to login leancloud. error: %@", error.description);
                } else {
                    ;
                }
            }];
        }
    } toPlatform:AVOSCloudSNSQQ];
}

- (IBAction)weixinLogin:(id)sender {
    
}

- (IBAction)renrenLogin:(id)sender {
    
}

@end
