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
@interface MyWebViewController () <WKUIDelegate, WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation MyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"start load session:%@", [self.requestURL absoluteString]);
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.requestURL]];
}


- (WKWebView *) webView {
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
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    [self.view addSubview:_webView];
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

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

//    NSMutableString *str = [NSMutableString string];
//    [str appendString:@"var header = document.getElementsByTagName(\"header\")[0];"];
//    [str appendString:@"header.parentNode.removeChild(header);"];
//    [str appendString:@"var footer = document.getElementsByTagName(\"footer\")[0];"];
//    [str appendString:@"footer.parentNode.removeChild(footer);"];
//
//    [self.webView evaluateJavaScript:str completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.webView.hidden = NO;
//        });
//    }];
}
@end
