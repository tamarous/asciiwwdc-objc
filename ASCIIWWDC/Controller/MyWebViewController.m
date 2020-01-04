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
#import <ReactiveObjC/ReactiveObjC.h>

@interface MyWebViewController() <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL dataSaved;
@property (nonatomic, strong) UIBarButtonItem *favorButtonItem;
@property (nonatomic, strong) RACCommand *saveContentCommand;
@property (nonatomic, strong) RACCommand *loadRequestCommand;
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
    self.favorButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFavorite)];

    self.navigationItem.rightBarButtonItem = self.favorButtonItem;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
   
    [self bindEvents];
    [[RACScheduler scheduler] schedule:^{
        [self.saveContentCommand execute:nil];
    }];
    [[RACScheduler mainThreadScheduler] schedule:^{
        [self.loadRequestCommand execute:nil];
    }];
}

- (void)bindEvents {
    [RACObserve(self.webView, estimatedProgress) subscribeNext:^(id  _Nullable x) {
        CGFloat newProgress = [(NSNumber *)x floatValue];
        self.progressView.alpha = 1.0f;
        [self.progressView setProgress:newProgress animated:YES];
        if (newProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.progressView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }];
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        UIEdgeInsets safeArea = self.view.safeAreaInsets;
        CGRect safeFrame = CGRectMake(safeArea.left, safeArea.top, self.view.frame.size.width, 1);
        _progressView = [[UIProgressView alloc] initWithFrame:safeFrame];
        _progressView.tintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor whiteColor];
    }
    return _progressView;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [ZWCacheURLProtocol stopHookNetwork];
}

- (void)toggleFavorite {
    UIView *itemView = [self.favorButtonItem performSelector:@selector(view)];
    UIImageView *imageView = [[itemView.subviews firstObject].subviews firstObject];
    
    if (self.session.isFavored) {
        self.favorButtonItem.image = [UIImage imageNamed:@"Unfavor"];
    } else {
        self.favorButtonItem.image = [UIImage imageNamed:@"Favor"];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingNone;
    imageView.clipsToBounds = NO;
    imageView.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:1.0 delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
        imageView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    self.session.isFavored = !self.session.isFavored;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DBManager sharedManager] updateModel:self.session];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Updated"];
            [SVProgressHUD dismissWithDelay:1.5];
        });
    });
}

- (WKWebView *)webView {
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
    }
    return _webView;
}

- (RACCommand *)saveContentCommand {
    if (!_saveContentCommand) {
        _saveContentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                [[DBManager sharedManager] saveModel:self.session];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _saveContentCommand;
}

- (RACCommand *)loadRequestCommand {
    if (!_loadRequestCommand) {
        @weakify(self);
        _loadRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self);
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self);
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.requestURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:6];
                [self.webView loadRequest:request];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _loadRequestCommand;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"didCommitNavigation");
}

- (void)webView:(WKWebView *) webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Fail navigation with Error:%@",error.description);
}

- (void)webView:(WKWebView *) webView didFailLoadWithError:(nonnull NSError *)error {
    NSLog(@"Fail load with Error:%@",error.description);
}

- (void)webView:(WKWebView *) webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    [SVProgressHUD dismissWithDelay:2];
}

@end
