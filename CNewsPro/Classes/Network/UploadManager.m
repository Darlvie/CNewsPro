//
//  UploadManager.m
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "UploadManager.h"
#import "UploadClient.h"
#import "UploadQueue.h"
#import "ManuscriptsDB.h"
#import "Manuscripts.h"

@implementation UploadManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _uploadQueue = [[UploadQueue alloc] init];
        _uploadQueue.maxClientCount = MAX_CLIENT_COUNT;
        _tagBeginNumber = 0;
    }
    return self;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static UploadManager *sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[UploadManager alloc] init];
    });
    return sharedManager;
}

- (NSInteger)uploadClientCount {
    return [self.uploadQueue count];
}

- (UploadClient *)getClientAtIndex:(NSInteger)index {
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    return client;
}

- (NSString *)getUploadRequestStatus:(NSInteger)index {
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    NSString *status = [client.uploadInfo objectForKey:REQUEST_STATUS];
    return status;
}

- (void)continueUploadClientAtQueueIndex:(NSInteger)index {
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    if (client.paused) {
        client.running = YES;
        //重置状态
        [client.uploadInfo setObject:REQUEST_SUCCESS forKey:REQUEST_STATUS];
        [client continueUpload];
    } else {
        [client.uploadInfo setObject:REQUEST_SUCCESS forKey:REQUEST_STATUS];
        [client startUpload];
    }
}

- (void)removeClientAtIndex:(NSUInteger)index {
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    ManuscriptsDB *mdb = [[ManuscriptsDB alloc] init];
    Manuscripts *manuscripts = (Manuscripts *)[client.uploadInfo objectForKey:MANUSCRIPT_INFO];
    [mdb setManuscriptStatus:MANUSCRIPT_STATUS_EDITING mId:manuscripts.m_id];
    
    [client cancelUpload];
    [self.uploadQueue removeObjectAtIndex:index];
    [self.uploadQueue awakeClients];
}

- (Manuscripts *)objectAtQueueIndex:(NSInteger)index {
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    Manuscripts *manuscript = [client.uploadInfo objectForKey:MANUSCRIPT_INFO];
    return manuscript;
}

//添加上传任务
- (void)uploadWithInfo:(NSMutableDictionary *)uploadInfo {
    //若当前队列中无上传任务，重置任务tagBeginNumber
    if ([self.uploadQueue count] == 0) {
        self.tagBeginNumber = 0;
    }
    
    UploadClient *client = [[UploadClient alloc] initWithDelegate:self info:uploadInfo];
    if ([[uploadInfo objectForKey:FILE_PATH] isEqualToString:@"0"]) {
        client.xmlOnly = 1;//表示无附件
    } else {
        client.xmlOnly = 0;
    }
    
    [uploadInfo setObject:[NSNumber numberWithUnsignedInteger:self.tagBeginNumber++] forKey:@"tag"];
    [self.uploadQueue addClient:client];
}

//暂停指定位置的client上传
- (void)pauseUploadClientAtQueueIndex:(NSInteger)index {
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    if(client.running)
    {
        [client pauseUpload];
    }
}

//将任务移除队列（在注销帐号时使用）
-(void)removeClient:(int)index {
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    [client cancelUpload];
    [self.uploadQueue removeObjectAtIndex:index];
}

-(void)removeClientByClient:(UploadClient *)client
{
    ManuscriptsDB *mdb = [[ManuscriptsDB alloc] init];
    Manuscripts *manuscripts=(Manuscripts *)[client.uploadInfo objectForKey:MANUSCRIPT_INFO];
    [mdb setManuscriptStatus:MANUSCRIPT_STATUS_EDITING mId:manuscripts.m_id];
    [client cancelUpload];
    [self.uploadQueue removeObject:client];
    [self.uploadQueue awakeClients];
}

- (NSString *)attachmentPathAtQueueIndex:(NSInteger)index {
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    NSString *path= [client.uploadInfo objectForKey:FILE_PATH];
    return path;
}

//返回队列中指定位置的client的上传进度
- (float)uploadProgressAtQueueIndex:(NSInteger)index
{
    UploadClient *client = [self.uploadQueue objectAtIndex:index];
    return client.progress;
}

@end
