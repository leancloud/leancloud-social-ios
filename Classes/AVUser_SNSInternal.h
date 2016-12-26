//
//  AVUser_Internal.h
//  LeanCloudSocial
//
//  Created by 陈宜龙 on 12/26/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

#import "AVUser.h"

#define AnonymousIdKey @"LeanCloud.AnonymousId"

@interface AVUser ()

@property (nonatomic, readwrite, copy) NSString *facebookToken;
@property (nonatomic, readwrite, copy) NSString *twitterToken;
@property (nonatomic, readwrite, copy) NSString *sinaWeiboToken;
@property (nonatomic, readwrite, copy) NSString *qqWeiboToken;
@property (nonatomic, readwrite) BOOL isNew;
@property (nonatomic, readwrite) BOOL mobilePhoneVerified;

- (BOOL)isAuthDataExistInMemory;

+ (AVUser *)userOrSubclassUser;

+ (NSString *)userTag;
+ (BOOL)isAutomaticUserEnabled;
+ (void)disableAutomaticUser;

+ (NSString *)endPoint;
- (NSString *)internalClassName;
- (void)setNewFlag:(BOOL)isNew;

+ (void)removeCookies;

- (NSArray *)linkedServiceNames;

@end
