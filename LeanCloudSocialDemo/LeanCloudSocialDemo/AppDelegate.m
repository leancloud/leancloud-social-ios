//
//  AppDelegate.m
//  LeanCloudSocialDemo
//
//  Created by Feng Junwen on 5/22/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "AppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>
#import "AVOSCloudSocial.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *appId = @"2jjvnj3938p6pns11r41dlte2n98bm6m7bkblm1cysttm7in";
    NSString *appKey = @"7dtvdetcfggpalwtf91pdoootc7csxx0vxyi3ayqtbnlklq2";
    [AVOSCloud setApplicationId:appId clientKey:appKey];
    NSLog(@"setAppId:%@, appKey:%@", appId, appKey);
    
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"3204693755" andAppSecret:@"4946001e214ce387693dde961c29e148" andRedirectURI:@"http://leansocial.avosapps.com"];
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ withAppKey:@"1104663626" andAppSecret:@"f48pqrZNcW2pmDLu" andRedirectURI:nil];
    
    [AVOSCloud setVerbosePolicy:kAVVerboseShow];
    [AVLogger addLoggerDomain:AVLoggerDomainIM];
    [AVLogger addLoggerDomain:AVLoggerDomainCURL];
    [AVLogger setLoggerLevelMask:AVLoggerLevelAll];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
