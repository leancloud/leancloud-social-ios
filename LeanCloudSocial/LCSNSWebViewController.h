//
//  AVSNSWebViewController.h
//  AVOS
//
//  Created by Qihe Bian on 11/28/14.
//
//

#import "LCWebViewController.h"
#import "LeanCloudSocial.h"
@interface LCSNSWebViewController : LCWebViewController
@property(nonatomic, copy)AVSNSResultBlock callback;
@end
