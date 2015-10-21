//
//  AVSNSTestCase.m
//  LeanCloudSocial
//
//  Created by lzw on 15/10/21.
//  Copyright © 2015年 LeanCloud. All rights reserved.
//
#import "AVSNSTestCase.h"

@implementation AVSNSTestCase

+ (void)setUp {
    [super setUp];
    NSString *appId = @"2jjvnj3938p6pns11r41dlte2n98bm6m7bkblm1cysttm7in";
    NSString *appKey = @"7dtvdetcfggpalwtf91pdoootc7csxx0vxyi3ayqtbnlklq2";
    [AVOSCloud setApplicationId:appId clientKey:appKey];
    [AVOSCloud setAllLogsEnabled:YES];
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Utils

- (void)waitNotification:(const void *)notification {
    NSString *name = [NSString stringWithFormat:@"%p", notification];
    [self expectationForNotification:name object:nil handler:nil];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)postNotification:(const void *)notification {
    NSString *name = [NSString stringWithFormat:@"%p", notification];
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

- (AVUser *)registerOrLoginWithUsername:(NSString *)username password:(NSString *)password {
    AVUser *user = [AVUser user];
    user.username = username;
    user.password = password;
    NSError *error;
    [user signUp:&error];
    if (!error) {
        return user;
    } else if (error.code == kAVErrorUsernameTaken){
        NSError *loginError;
        AVUser *loginUser = [AVUser logInWithUsername:username password:password error:&loginError];
        XCTAssertNil(loginError);
        return loginUser;
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"can not sign up or login"];
        return nil;
    }
}


@end
