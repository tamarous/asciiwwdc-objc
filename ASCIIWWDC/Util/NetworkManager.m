//
// Created by 汪泽伟 on 2019/12/28.
// Copyright (c) 2019 Wang Zewei. All rights reserved.
//

#import "NetworkManager.h"
#import "DBManager.h"
#import "ParserManager.h"
#import <AFNetworking/AFNetworking.h>
@interface NetworkManager()

@end

@implementation NetworkManager
+ (void)loadConferencesFromURL:(NSString *)urlString completion:(void (^)(NSArray *conferences, NSError *error))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" forHTTPHeaderField:@"Accept"];

    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = responseSerializer;
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            !completion ?: completion(nil, error);
            NSLog(@"error: %@", error.domain.description);
        } else {
            NSArray *conferences = [[ParserManager sharedManager]  createConferencesArrayFromResponseObject:responseObject];
            !completion ?: completion(conferences, nil);
        }
    }];
    [dataTask resume];
}
@end