//
//  DataManager.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "DataManager.h"

typedef NS_ENUM(NSInteger, RequestMethod) {
    RequestMethodHTTPGet = 1,
    RequestMethodHTTPPost = 2,
};
typedef void(^requestSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^requestErrorBlock)(NSError *error);

@interface DataManager()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, copy) NSString *userAgentMobile;
@property (nonatomic, copy) NSString *userAgentPC;
@end


@implementation DataManager

- (AFHTTPSessionManager *) sessionManager {
    if (! _sessionManager) {
        NSString *baseUrl = @"http://www.asciiwwdc.com/";
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sessionManager.requestSerializer.HTTPShouldHandleCookies = YES;
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _sessionManager;
}


- (instancetype) init {
    if (self = [super init]) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        
        self.userAgentMobile = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        self.userAgentPC = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14";
    }
    
    return self;
}



+ (instancetype) sharedManager {
    static DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    return manager;
}


- (NSURLSessionDataTask *) requestWithMethod:(RequestMethod) method
                                   urlString:(NSString *) urlString
                                  parameters:(NSDictionary *) parameters
                                     success:(requestSuccessBlock) success
                                     failure:(requestErrorBlock) failure {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    
    void (^handleSuccessResponseBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        success(task, responseObject);
    };
    
    void (^handleFailedResponseBlock)(NSURLSessionDataTask *task, NSError * _Nonnull error) = ^(NSURLSessionDataTask *task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"Error: %@", task.originalRequest.description);
        failure(error);
    };
    
    
    NSURLSessionDataTask *task = nil;
    if (method == RequestMethodHTTPGet) {
        task = [self.sessionManager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            handleSuccessResponseBlock(task,responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            handleFailedResponseBlock(task, error);
        }];
    } else if (method == RequestMethodHTTPPost) {
        task = [self.sessionManager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            handleSuccessResponseBlock(task,responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            handleFailedResponseBlock(task, error);
        }];
    }

    return task;
}

@end
