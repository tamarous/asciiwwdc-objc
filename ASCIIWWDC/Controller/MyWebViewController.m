//
//  WebViewController.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/19.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "MyWebViewController.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WKUserContentController.h>
#import <WebKit/WKUserScript.h>
#import <WebKit/WKWebViewConfiguration.h>
#import "DBManager.h"
#import <SVProgressHUD.h>
#import "ZWCacheURLProtocol.h"

@interface MyWebViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL dataSaved;
@property (nonatomic, strong) UIBarButtonItem *favorButtonItem;
@end

@implementation MyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ZWCacheURLProtocol startHookNetwork];
    
    
    
    
    self.navigationItem.title = self.session.title;
    [self.navigationItem.titleView sizeToFit];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    self.navigationController.navigationBar.translucent = NO;
    
    NSString *imageName = (self.session.isFavored ? @"Favor":@"Unfavor");
    self.favorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];

    self.navigationItem.rightBarButtonItem = self.favorButtonItem;
    
    [self save];
    
    [self loadRequest];
}

- (void) loadRequest {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.requestURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:6];
    [self.webView loadRequest:request];
}

- (UIProgressView *) progressView {
    if (_progressView == nil) {
        UIEdgeInsets safeArea = self.view.safeAreaInsets;
        CGRect safeFrame = CGRectMake(safeArea.left, safeArea.top, self.view.frame.size.width, 1);
        _progressView = [[UIProgressView alloc] initWithFrame:safeFrame];
        _progressView.tintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor whiteColor];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}


- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskPortrait;
}

- (void) dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    
    [ZWCacheURLProtocol stopHookNetwork];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newProgress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.progressView.alpha = 1.0f;
        [self.progressView setProgress:newProgress animated:YES];
        if (newProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.progressView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void) favorite {
    UIView *itemView = [self.favorButtonItem performSelector:@selector(view)];
    UIImageView *imageView = [[itemView.subviews firstObject].subviews firstObject];
    
    if (self.session.isFavored) {
        self.favorButtonItem.image = [UIImage imageNamed:@"Unfavor"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingNone;
        imageView.clipsToBounds = NO;
        imageView.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:1.0 delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
            imageView.transform = CGAffineTransformIdentity;
        } completion:nil];
    } else {
        self.favorButtonItem.image = [UIImage imageNamed:@"Favor"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingNone;
        imageView.clipsToBounds = NO;
        imageView.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:1.0 delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
            imageView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    
    [self toggleFavored];
}

- (void) toggleFavored {
    self.session.isFavored = !self.session.isFavored;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DBManager sharedManager] updateSession:self.session];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Updated"];
            [SVProgressHUD dismissWithDelay:1.5];
        });
    });
}

- (void) save {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DBManager sharedManager] saveSession:self.session];
    });
}

- (WKWebView *) webView {
    if (!_webView) {
        NSMutableString *str = [NSMutableString string];
        [str appendString:@"var header = document.getElementsByTagName(\"header\")[0];"];
        [str appendString:@"header.parentNode.removeChild(header);"];
        [str appendString:@"var footer = document.getElementsByTagName(\"footer\")[0];"];
        [str appendString:@"footer.parentNode.removeChild(footer);"];
    
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:str injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        WKUserContentController *contentController = [[WKUserContentController alloc] init];
        [contentController addUserScript:userScript];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = contentController;
        configuration.selectionGranularity = WKSelectionGranularityDynamic;
        
        UIEdgeInsets safeArea = self.view.safeAreaInsets;
        CGRect safeFrame = CGRectMake(safeArea.left, safeArea.top, self.view.frame.size.width, self.view.frame.size.height);
        _webView = [[WKWebView alloc] initWithFrame:safeFrame configuration:configuration];
        _webView.navigationDelegate = self;
        
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKNavigationDelegate
- (void) webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"didCommitNavigation");
}

- (void) webView:(WKWebView *) webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation");
}

- (void) webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Fail navigation with Error:%@",error.description);
}

- (void) webView:(WKWebView *) webView didFailLoadWithError:(nonnull NSError *)error {
    NSLog(@"Fail load with Error:%@",error.description);
}

- (void) webView:(WKWebView *) webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    [SVProgressHUD dismissWithDelay:2];
}

@end
