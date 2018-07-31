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

@interface MyWebViewController () <WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL dataSaved;
@property (nonatomic, strong) UIBarButtonItem *favorButtonItem;
@end

@implementation MyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.session.title;
    [self.navigationItem.titleView sizeToFit];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;

    
    NSString *imageName = (self.session.isFavored ? @"Favor":@"Unfavor");
    self.favorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
    
    
    self.navigationItem.rightBarButtonItem = self.favorButtonItem;
    
    NSLog(@"start load session:%@", [self.requestURL absoluteString]);
    
    [self save];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.requestURL]];
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
        
        UIEdgeInsets safeArea = self.view.safeAreaInsets;
        CGRect safeFrame = CGRectMake(safeArea.left, safeArea.top, self.view.frame.size.width, self.view.frame.size.height);
        _webView = [[WKWebView alloc] initWithFrame:safeFrame configuration:configuration];
        _webView.UIDelegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKUIDelegate

#pragma mark - WKNavigationDelegate
- (void) webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

- (void) webView:(WKWebView *) webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
}
@end
