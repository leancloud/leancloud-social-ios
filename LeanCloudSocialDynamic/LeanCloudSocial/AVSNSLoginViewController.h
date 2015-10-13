//
//  AVSNSLoginViewController.h
//  AVOSCloudSNS
//
//  Created by Travis on 13-10-21.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import "AVWebViewController.h"

@interface AVSNSLoginViewController :AVWebViewController
@property(nonatomic) AVOSCloudSNSType type;

-(void)loginToPlatform:(AVOSCloudSNSType)type;

@end
