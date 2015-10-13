//
//  AVWebViewController.h
//  AVOS
//
//  Created by Qihe Bian on 11/28/14.
//
//

#import <UIKit/UIKit.h>

@interface AVWebViewController : UIViewController<UIWebViewDelegate>
@property(nonatomic,retain) UIWebView *webView;
-(void)close;
@end
