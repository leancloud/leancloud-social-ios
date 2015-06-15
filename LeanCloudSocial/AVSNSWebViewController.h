//
//  AVSNSWebViewController.h
//  AVOS
//
//  Created by Qihe Bian on 11/28/14.
//
//

#import "AVWebViewController.h"
#import "AVOSCloudSocial.h"
@interface AVSNSWebViewController : AVWebViewController
@property(nonatomic, copy)AVSNSResultBlock callback;
@end
