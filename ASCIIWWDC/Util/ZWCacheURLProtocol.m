//
//  ZWCacheURLProtocol.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/8/2.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "ZWCacheURLProtocol.h"
#import "NSURLProtocol+WkWebView.h"
@interface ZWURLCacheConfig:NSObject

@property (nonatomic, strong) NSMutableDictionary *urlDict;
@property (nonatomic, assign) NSInteger requestInterval;
@property (nonatomic, strong) NSURLSessionConfiguration *config;
@property (nonatomic, strong) NSOperationQueue *foregroundQueue;
@property (nonatomic, strong) NSOperationQueue *backgroundQueue;
@end

@implementation ZWURLCacheConfig

- (NSInteger) requestInterval {
    if (_requestInterval == 0) {
        _requestInterval = 7 * 24 * 60 * 60;
    }
    return _requestInterval;
}

- (NSURLSessionConfiguration *) config {
    if (!_config) {
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _config;
}

- (NSMutableDictionary *)urlDict {
    if (! _urlDict) {
        _urlDict = [NSMutableDictionary dictionary];
    }
    return _urlDict;
}

- (NSOperationQueue *) foregroundQueue {
    if (!_foregroundQueue) {
        _foregroundQueue = [[NSOperationQueue alloc] init];
        [_foregroundQueue setMaxConcurrentOperationCount:6];
    }
    return _foregroundQueue;
}

- (NSOperationQueue *) backgroundQueue {
    if (! _backgroundQueue) {
        _backgroundQueue = [[NSOperationQueue alloc] init];
        [_backgroundQueue setMaxConcurrentOperationCount:6];
    }
    return _backgroundQueue;
}

+ (instancetype) sharedInstance {
    static ZWURLCacheConfig *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ZWURLCacheConfig alloc] init];
    });
    return shared;
}

- (void) clearUrlDict {
    [[ZWURLCacheConfig sharedInstance].urlDict removeAllObjects];
    [ZWURLCacheConfig sharedInstance].urlDict = nil;
}
@end


static NSString *const AlreadyHandledKey = @"alreadyHandled";
static NSString *const checkUpdateInBackgroundKey = @"checkUpdateInBackgroundKey";

@interface ZWCacheURLProtocol()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLResponse *response;
@end


@implementation ZWCacheURLProtocol
+ (void) startHookNetwork {
    
    [NSURLProtocol wk_registerScheme:@"http"];
    [NSURLProtocol wk_registerScheme:@"https"];
    [NSURLProtocol registerClass:[ZWCacheURLProtocol class]];
}

+ (void)stopHookNetwork {
    
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
    [NSURLProtocol unregisterClass:[ZWCacheURLProtocol class]];
}


+ (void) setConfig:(NSURLSessionConfiguration *)config {
    [[ZWURLCacheConfig sharedInstance] setConfig:config];
}

+ (void) setRequestInterval:(NSInteger)requestInterval {
    [[ZWURLCacheConfig sharedInstance] setRequestInterval:requestInterval];
}

+ (void) clearUrlDicts {
    [[ZWURLCacheConfig sharedInstance] clearUrlDict];
}

+ (BOOL) canInitWithRequest:(NSURLRequest *)request {
    NSString *urlScheme = [[request URL] scheme];
    if ([urlScheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [urlScheme caseInsensitiveCompare:@"https"]) {
        if ([NSURLProtocol propertyForKey:AlreadyHandledKey inRequest:request]) {
            return NO;
        }
    }
    return YES;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void) backgroundCheckUpdate {
    __weak typeof(self) weakSelf = self;
    [[[ZWURLCacheConfig sharedInstance] backgroundQueue] addOperationWithBlock:^{
        NSDate *updateDate = [[ZWURLCacheConfig sharedInstance].urlDict objectForKey:weakSelf.request.URL.absoluteString];
        if (updateDate) {
            NSDate *currentDate = [NSDate date];
            NSInteger interval = [currentDate timeIntervalSinceDate:updateDate];
            if (interval < [ZWURLCacheConfig sharedInstance].requestInterval) {
                return;
            }
        }
        
        NSMutableURLRequest *mutableRequest = [[weakSelf request] mutableCopy];
        [NSURLProtocol setProperty:@YES forKey:AlreadyHandledKey inRequest:mutableRequest];
        [weakSelf startRequestWithRequest:mutableRequest];
    }];
}

- (void) startRequestWithRequest:(NSURLRequest *)request {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[ZWURLCacheConfig sharedInstance].foregroundQueue];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [[ZWURLCacheConfig sharedInstance].urlDict setValue:[NSDate date] forKey:self.request.URL.absoluteString];
    [task resume];
}


- (void) startLoading {
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[self request]];
    if (urlResponse) {
        [self.client URLProtocol:self didReceiveResponse:urlResponse.response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:urlResponse.data];
        [self.client URLProtocolDidFinishLoading:self];
        [self backgroundCheckUpdate];
        return;
    }
    
    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:AlreadyHandledKey inRequest:mutableRequest];
    [self startRequestWithRequest:mutableRequest];
}

- (void) stopLoading {
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (BOOL) isUseCache {
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[self request]];
    if (urlResponse) {
        return YES;
    }
    return NO;
}

- (void) appendData:(NSData *) newData {
    if ([self data] == nil) {
        [self setData:[newData mutableCopy]];
    } else {
        [[self data] appendData:newData];
    }
}

#pragma mark -NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.client URLProtocol:self didLoadData:data];
    
    [self appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
        if (!self.data) {
            return;
        }
        NSCachedURLResponse *cacheUrlResponse = [[NSCachedURLResponse alloc] initWithResponse:task.response data:self.data];
        [[NSURLCache sharedURLCache] storeCachedResponse:cacheUrlResponse forRequest:self.request];
        self.data = nil;
    }
}

@end



