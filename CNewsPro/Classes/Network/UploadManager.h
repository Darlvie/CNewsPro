//
//  UploadManager.h
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UploadClient,UploadQueue,Manuscripts;

@interface UploadManager : NSObject

@property (nonatomic,strong) UploadQueue *uploadQueue;
@property (nonatomic,assign) NSInteger tagBeginNumber;

+ (instancetype)sharedManager;

/**
 *  返回队列中上传client个数
 */
-(NSInteger)uploadClientCount;

- (UploadClient *)getClientAtIndex:(NSInteger)index;

/**
 *  返回client状态（失败或成功）
 */
- (NSString *)getUploadRequestStatus:(NSInteger)index;

/**
 *  恢复指定位置的client上传
 */
-(void)continueUploadClientAtQueueIndex:(NSInteger)index;

/**
 *  删除某个上传任务
 */
-(void)removeClientAtIndex:(NSUInteger)index;

//返回队列中的稿件信息
- (Manuscripts *)objectAtQueueIndex:(NSInteger)index;

//添加上传任务
- (void)uploadWithInfo:(NSMutableDictionary*)uploadInfo;

//返回队列中指定位置的client的上传进度
- (float)uploadProgressAtQueueIndex:(NSInteger)index;

//暂停指定位置的client上传
- (void)pauseUploadClientAtQueueIndex:(NSInteger)index;

//将任务移除队列（在注销帐号时使用）
- (void)removeClient:(int)index;

//删除上传任务
- (void)removeClientByClient:(UploadClient *)client;

//返回附件路径
- (NSString *)attachmentPathAtQueueIndex:(NSInteger)index;

@end
