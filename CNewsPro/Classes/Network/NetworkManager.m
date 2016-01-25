//
//  NetworkManager.m
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "NetworkManager.h"
#import "CommonClient.h"

static NSUInteger kCommonQueueMaxCount = 3;
static NSUInteger kUploadQueueMaxCount = 1;
static NSUInteger kPicQueueMaxCount    = 10;

@implementation NetworkManager

- (instancetype)init {
    if (self = [super init]) {
        //数据请求队列
        self.commonQueue = [[ASINetworkQueue alloc] init];
        self.commonQueue.maxConcurrentOperationCount = kCommonQueueMaxCount;
        self.commonQueue.shouldCancelAllRequestsOnFailure = NO;
        [self.commonQueue go];
        
        //图片请求队列
        self.pictureQueue = [[ASINetworkQueue alloc] init];
        self.pictureQueue.maxConcurrentOperationCount = kPicQueueMaxCount;
        self.pictureQueue.shouldCancelAllRequestsOnFailure = NO;
        [self.pictureQueue go];
        
        self.picUrlArray = [[NSMutableArray alloc] init];
    }
    return self;
}


+ (instancetype)sharedManager {
    static NetworkManager *networkManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[NetworkManager alloc] init];
    });
    return networkManager;
}

- (void)dealloc {
    [self.commonQueue cancelAllOperations];
    [self.pictureQueue cancelAllOperations];
    self.commonQueue = nil;
    self.pictureQueue = nil;
    
    self.picUrlArray = nil;
}

#pragma mark - 请求数据
- (void)requestDataWithDelegate:(id)delegate info:(id)requestInfo {
    CommonClient *client = [[CommonClient alloc] initWithDelegate:delegate info:requestInfo];
    [self.commonQueue addOperation:client];
}

//取消某个对象的所有数据请求
- (void)cancelRequestForDelegate:(id)delegate {
    NSArray *clients = [self.commonQueue operations];
    for (CommonClient *commonClient in clients) {
        if ([commonClient.callBack isEqual:delegate]) {
            [commonClient clearDelegatesAndCancel];
        }
    }
}
























@end
