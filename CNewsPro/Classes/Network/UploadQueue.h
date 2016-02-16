//
//  UploadQueue.h
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UploadClient;
@interface UploadQueue : NSObject

@property (nonatomic,assign) int maxClientCount;

- (NSUInteger)count;

- (UploadClient *)objectAtIndex:(NSUInteger)index;

- (void)removeObjectAtIndex:(NSUInteger)index;

/**
 *  唤醒队列中未启动的clients
 */
- (void)awakeClients;

//添加client到上传队列中
- (void)addClient:(UploadClient*)client;

- (void)removeObject:(UploadClient*)client;

- (void)removeObjectWithTag:(NSUInteger)tag;

@end
