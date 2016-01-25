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











@end
