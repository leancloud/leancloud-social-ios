//
//  AVSNSTestCase.h
//  LeanCloudSocial
//
//  Created by lzw on 15/10/21.
//  Copyright © 2015年 LeanCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <LeanCloudSocial/AVOSCloudSNS.h>
#import <AVOSCloud/AVOSCloud.h>
#import <Expecta/Expecta.h>

const static void *AVOSCloudSNSNotifation = &AVOSCloudSNSNotifation;

#define WAIT [self waitNotification:AVOSCloudSNSNotifation];
#define NOTIFY [self postNotification:AVOSCloudSNSNotifation];

@interface AVSNSTestCase : XCTestCase

- (void)waitNotification:(const void *)notification;
- (void)postNotification:(const void *)notification;

- (AVUser *)registerOrLoginWithUsername:(NSString *)username password:(NSString *)password;

@end