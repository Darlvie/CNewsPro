//
//  UploadQueue.m
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "UploadQueue.h"
#import "UploadClient.h"

@interface UploadQueue()
@property (nonatomic,strong) NSMutableArray *queue;
@end

@implementation UploadQueue

- (instancetype)init {
    if (self = [super init]) {
        self.maxClientCount = 2;
        self.queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count {
    return self.queue.count;
}

- (UploadClient *)objectAtIndex:(NSUInteger)index {
    if (index >= self.queue.count) {
        return nil;
    }
    return [self.queue objectAtIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.queue removeObjectAtIndex:index];
}

//唤醒最大队列中未启动的clients
- (void)awakeClients {
    NSUInteger availableCount = self.maxClientCount <= self.queue.count? self.maxClientCount : self.queue.count;
    for (int i = 0; i < availableCount; i ++) {
        UploadClient *client = (UploadClient *)[self.queue objectAtIndex:i];
        if (!client.running & !client.paused) {
            [client startUpload];
        }
    }
}

//添加client到队列中
- (void)addClient:(UploadClient *)client {
    [self.queue addObject:client];
     //若在最大可运行的上传进程内，开始上传进程
    if (self.queue.count <= self.maxClientCount) {
        [client startUpload];
    }
}
















@end
