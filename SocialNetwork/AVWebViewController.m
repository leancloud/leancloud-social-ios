//
//  AVWebViewController.m
//  AVOS
//
//  Created by Qihe Bian on 11/28/14.
//
//

#import "AVWebViewController.h"

@interface AVWebViewController ()

@end

@implementation AVWebViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.webView=[[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.webView.delegate=self;
        self.webView.scalesPageToFit=YES;
        [self.view addSubview:self.webView];
        
    }
    return self;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(void)dispatchActionWithURL:(NSURL *)url {
    
}

-(void)close{
    if ([self.navigationController isBeingPresented]||
        [self.navigationController isBeingDismissed]
        ) {
        [self performSelector:@selector(close) withObject:nil afterDelay:0.25];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    if ([[url.scheme lowercaseString] isEqualToString:@"leancloud"]) {
        [self dispatchActionWithURL:url];
        return NO;
    } else {
        return YES;
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if ((error.code==101 || error.code == 102) && [error.domain isEqualToString:@"WebKitErrorDomain"]) {
        //ignore
    }else{
        NSLog(@"%@", error);
    }
    
}
@end

