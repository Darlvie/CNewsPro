//
//  CommonClient.m
//  CNewsPro
//
//  Created by zyq on 16/1/21.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "CommonClient.h"

@implementation CommonClient

- (id)initWithDelegate:(id)aDelegate info:(id)requestInfo {
    NSString *strURL = [requestInfo objectForKey:REQUEST_URL];
    NSURL *requestURL = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    self = [super initWithURL:requestURL];
    if (self) {
        if ([[requestInfo objectForKey:REQUEST_METHOD] isEqual:POST]) {
            NSString *bodyStr = [requestInfo objectForKey:POST_BODY];
            [self addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            [self appendPostData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
            [self setRequestMethod:POST];
        }
        self.delegate = self;
        self.callBack = aDelegate;
        self.responseInfo = requestInfo;
        self.timeOutSeconds = TIMEOUT_INTERVAL;
        self.shouldAttemptPersistentConnection = NO;
    }
    return self;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData *respData = [self responseData];
    if (respData) {
        [self.responseInfo setObject:REQUEST_SUCCESS forKey:REQUEST_STATUS];
        [self.responseInfo setObject:respData forKey:RESPONSE_DATA];
    } else {
        NSLog(@"response data is null");
    }
    [self.callBack performSelector:@selector(requestDidFinish:) withObject:self.responseInfo];
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    @try {
        [self.responseInfo setObject:REQUEST_FAIL forKey:REQUEST_STATUS];
        [self.responseInfo setObject:@"服务器无响应" forKey:RESPONSE_ERROR];
        NSLog(@"request failed");
        [self.callBack performSelector:@selector(requestDidFinish:) withObject:self.responseInfo];

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}







@end
