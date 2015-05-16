//
//  AVSNSLoginViewController.h
//  AVOSCloudSNS
//
//  Created by Travis on 13-10-21.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import "LCWebViewController.h"

@interface LCSNSLoginViewController :LCWebViewController
@property(nonatomic) AVOSCloudSNSType type;

-(void)loginToPlatform:(AVOSCloudSNSType)type;

@end
