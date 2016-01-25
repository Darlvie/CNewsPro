//
//  UploadClient.m
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "UploadClient.h"
#import "Utility.h"
#import "AppDelegate.h"
#import "RequestMaker.h"
#import "Manuscripts.h"
#import "UploadManager.h"
#import "User.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSData+LTExtension.h"

typedef NS_ENUM(NSUInteger,UploadType)
{
    UploadTypeWhole,             //一次性上传
    UploadTypeEmptyNew,          //上传第一步
    UploadTypePart,              //上传第二步
    UploadTypeConfirm,           //上传第三步
    UploadTypeSaveFile,
    UploadTypeXML,
    UploadTypeSaveNews
};

@interface UploadClient () <ASIHTTPRequestDelegate>
// 记录文件长度
@property (nonatomic,assign) NSUInteger fileLength;
// 记录上传位置
@property (nonatomic,assign) NSUInteger filePosition;
// 记录xml长度
@property (nonatomic,assign) NSUInteger xmlLength;

@property (nonatomic,strong) ASIHTTPRequest *client;

@property (nonatomic,strong) ASIFormDataRequest *dataClient;
/** 重传次数 */
@property (nonatomic,assign) NSInteger reloadCount;
/** 上一块的大小 */
@property (nonatomic,assign) NSInteger lastUploadBlockSize;

@end
@implementation UploadClient

- (instancetype)initWithDelegate:(id)aDelegate info:(id)uploadInfo {
    if (self = [super init]) {
        self.delegate = aDelegate;
        self.uploadInfo = uploadInfo;
        self.filePosition = 0;
        self.progress = 0.f;
        self.beginUp = 0.f;
        self.fileLength = [Utility getFileLengthByPath:[uploadInfo objectForKey:FILE_PATH]];
        self.xmlLength = [Utility getFileLengthByPath:[uploadInfo objectForKey:XML_PATH]];
        if ([[USERDEFAULTS objectForKey:RE_SEND_COUNT] intValue] == 0) {
            self.reloadCount = 1;
        } else {
            self.reloadCount = [[USERDEFAULTS objectForKey:RE_SEND_COUNT] intValue];
        }
        self.running = NO;
        self.paused = NO;
        self.currentIndexPath = 1;
    }
    return self;
}

//开始上传
- (void)startUpload {
    NSDate *newDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDateOne = [dateFormat stringFromDate:newDate];
    [dateFormat setDateStyle:NSDateFormatterFullStyle];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    self.paused = NO;
    self.running = YES;
    //判定重传次数
    if (self.reloadCount < 0) {
        //重传次数<0后，不再自动重传
        self.paused = YES;
        [self.uploadInfo setObject:LAST_FAIL forKey:REQUEST_STATUS];
        return;
    } else {
        self.reloadCount -= 1;
    }
    
    NSUInteger tag = [[self.uploadInfo objectForKey:@"tag"] unsignedIntValue];
    [self.uploadInfo setObject:@"" forKey:REQUEST_STATUS];
    //检测网络连接状况，如果未连接网络，不发送
    if (![Utility testConnection]) {
        self.paused = YES;
        [self.uploadInfo setObject:LAST_FAIL forKey:REQUEST_STATUS];
        [NOTIFICATION_CENTER postNotificationName:UPDATE_UPLOAD_PROGRESS_NOTIFICATION object:nil];
    }
    
    //判断sessionId是否存在（为空表示离线登录，需要重新获取）
    if ([[USERDEFAULTS objectForKey:SESSION_ID] isEqualToString:@""]) {
        if ([[Utility sharedSingleton].urlArray count]== 0) {
            [Utility getUrlArray];
            if ([[Utility sharedSingleton].urlArray count] == 0) {
                self.paused = YES;
                [self.uploadInfo setObject:LAST_FAIL forKey:REQUEST_STATUS];
                [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"入口服务器获取失败!"];
                return;
            }
        }
        NSString *returnStr = [RequestMaker syncLoginWithUerName:[USERDEFAULTS objectForKey:LOGIN_NAME]
                                                        password:[USERDEFAULTS objectForKey:PASSWORD]];
        if ([[returnStr componentsSeparatedByString:@"||"] count] > 1) {
            if ([[[returnStr componentsSeparatedByString:@"||"] objectAtIndex:0] isEqualToString:@"0"]) {
                NSString *sessionId = [[returnStr componentsSeparatedByString:@"||"] lastObject];
                [USERDEFAULTS setObject:sessionId forKey:SESSION_ID];
            } else {
                [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"session校验失败!"];
                self.paused = YES;
                [self.uploadInfo setObject:LAST_FAIL forKey:REQUEST_STATUS];
                [NOTIFICATION_CENTER postNotificationName:UPDATE_UPLOAD_PROGRESS_NOTIFICATION object:nil];
                return;
            }
        } else {
            self.paused = YES;
            [self.uploadInfo setObject:LAST_FAIL forKey:REQUEST_STATUS];
            [NOTIFICATION_CENTER postNotificationName:UPDATE_UPLOAD_PROGRESS_NOTIFICATION object:nil];
            return;
        }
    }
    
    if (self.xmlOnly == 1) {
        //获取要上传文件的长度
        self.fileLength = [Utility getFileLengthByPath:[self.uploadInfo objectForKey:XML_PATH]];
    } else {
        self.fileLength = [Utility getFileLengthByPath:[self.uploadInfo objectForKey:FILE_PATH]];
    }
    
    //发稿地址校验
    Manuscripts *manuscripts = [self.uploadInfo objectForKey:MANUSCRIPT_INFO];
    if (![Utility checkSendToAddress:[Utility sharedSingleton].userInfo manuscriptTemplate:manuscripts.mTemplate]) {
        [[UploadManager sharedManager] removeClientAtIndex:tag];
        [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"发稿通道校验失败,任务移除待发队列"];
        return;
    }
    
    if ([Utility sharedSingleton].userInfo == nil) {
        [Utility getUserInfo];
        if ([Utility sharedSingleton].userInfo == nil) {
            return;
        }
    }
    
    //用户权限校验
    if (![[Utility sharedSingleton].userInfo.rightDisabled isEqualToString:@"false"]) {
        [[UploadManager sharedManager] removeClientAtIndex:tag];
        [[AppDelegate getAppDelegate] alert:AlertTypeError message:@"用户权限校验失败,任务移除待发队列"];
        return;
    }
    
    if (self.xmlOnly == 1) {
        [self uploadWholeFile];
    } else {
        [self uploadEmptyNewFile];
    }
}

//取消上传
- (void)cancelUpload {
    [self.client clearDelegatesAndCancel];
    [self.dataClient clearDelegatesAndCancel];
}

//暂停上传
- (void)pauseUpload {
    if (!self.paused) {
        self.paused = YES;
        self.running = NO;
        //根据进度判断当前处于上传处于哪一个环节
        if (self.progress != 0 && self.progress != 1) {
            //处于传递分块阶段
            if (self.filePosition >= self.lastUploadBlockSize) {
                self.filePosition = self.filePosition - self.lastUploadBlockSize;//失败后重传这个分块
            }
        }
        [self.dataClient clearDelegatesAndCancel];
    } else {
        NSLog(@"暂停失败！");
    }
}

//恢复上传
- (void)continueUpload {
    if (self.paused && self.running) {
        self.paused = NO;
        self.running = TRUE;
        [self uploadPartFileWithServerFileID:self.serverFileID
                                       range:NSMakeRange(self.filePosition, BLOCK_SIZE)];
    }
}

/**
 *  三合一传输小文件
 */
- (void)uploadWholeFile {
    if (self.xmlOnly == 1) {
        NSData *xmlData = [NSData dataWithContentsOfFile:[self.uploadInfo objectForKey:XML_PATH]];
        NSString *rangStr = [NSString stringWithFormat:@"0-%ld@%ld",self.xmlLength - 1,self.xmlLength];
        
        NSString *url = [NSString stringWithFormat:@"%@%@",MITI_IP,@"mServices!uploadWholeFile.action"];
        self.dataClient = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
        self.dataClient.tag = UploadTypeWhole;
        self.dataClient.delegate = self;
        
        [self.dataClient setPostValue:[USERDEFAULTS objectForKey:SESSION_ID] forKey:@"sss"];
        [self.dataClient setPostValue:[NSString stringWithFormat:@"%ld",self.xmlLength] forKey:@"len"];
        [self.dataClient setPostValue:@"0" forKey:@"compressFlag"];
        [self.dataClient setPostValue:@"0" forKey:@"encryptFlag"];
        [self.dataClient setPostValue:[xmlData MD5] forKey:@"checkCode"];
        [self.dataClient setPostValue:@"1" forKey:@"checkFlag"];
        [self.dataClient setData:xmlData withFileName:@"file"
                  andContentType:[NSString stringWithFormat:@"%@",rangStr]
                          forKey:@"fileDate"];
        [self.dataClient startAsynchronous];
    } else {
        NSData *fileData = [NSData dataWithContentsOfFile:[self.uploadInfo objectForKey:FILE_PATH]];
        NSString *rangeStr = [NSString stringWithFormat:@"0-%ld@%ld",self.fileLength-1,self.fileLength];
        
        NSString *url = [NSString stringWithFormat:@"%@%@",MITI_IP,@"mServices!uploadWholeFile.action"];
        self.dataClient = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
        self.dataClient.tag = UploadTypeWhole;
        self.dataClient.delegate = self;
        
        [self.dataClient setPostValue:@"file.upwhole" forKey:@"ua"];
        [self.dataClient setPostValue:[USERDEFAULTS objectForKey:SESSION_ID] forKey:@"sss"];
        [self.dataClient setPostValue:[NSString stringWithFormat:@"%ld",self.fileLength] forKey:@"len"];
        [self.dataClient setPostValue:@"0" forKey:@"compressFlag"];
        [self.dataClient setPostValue:@"0" forKey:@"encryptFlag"];
        [self.dataClient setData:fileData withFileName:@"file"
                  andContentType:[NSString stringWithFormat:@"%@",rangeStr]
                          forKey:[NSString stringWithFormat:@"%@/%@",[fileData MD5],@"1"]];
        [self.dataClient startAsynchronous];

    }
}

/**
 *  发送文件步骤一：传输新文件
 */
- (void)uploadEmptyNewFile {
    NSString *url = [NSString stringWithFormat:@"%@%@",MITI_IP,@"mServices!uploadStart.action"];
    NSString *bodyStr = [NSString stringWithFormat:@"sss=%@&len=%lu",
                         [USERDEFAULTS objectForKey:@"session_id"],
                         (unsigned long)self.fileLength];
    self.client = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    self.client.tag = UploadTypeEmptyNew;
    [self.client setDelegate:self];
    self.client.timeOutSeconds = TIMEOUT_INTERVAL;
    [self.client addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [self.client appendPostData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    [self.client setRequestMethod:POST];
    [self.client startAsynchronous];
}

/**
 *  发送文件步骤二：循环传输部分数据
 *
 */
-(void)uploadPartFileWithServerFileID:(NSString*)fileId range:(NSRange)range {
    
    self.beginUp = (double)[[NSDate date] timeIntervalSince1970] * 1000.f;
    //若已暂停标识位，暂停上传
    if (self.paused) {
        return;
    }
    
    //处理最后一个长度不足BlockSize的数据包大小
    if (self.filePosition + BLOCK_SIZE > self.fileLength) {
        range.length = self.fileLength - self.filePosition;
    }
    
    NSString *rangeStr = [NSString stringWithFormat:@"%ld-%ld@%lu",range.location,
                         range.location + range.length - 1,
                         self.fileLength];
    NSString *url=[NSString stringWithFormat:@"%@%@",MITI_IP,@"mServices!uploadResume.action"];
    self.dataClient = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    self.dataClient.tag = UploadTypePart;
    self.dataClient.delegate = self;
    
    NSData *subData = [Utility subDataWithRange:range filePath:[self.uploadInfo objectForKey:FILE_PATH]];
    [self.dataClient setPostValue:[USERDEFAULTS objectForKey:SESSION_ID] forKey:@"sss"];
    [self.dataClient setPostValue:fileId forKey:@"fid"];
    
    [self.dataClient setPostValue:@"0000000000" forKey:@"checkCode"];
    [self.dataClient setPostValue:@"1" forKey:@"checkFlag"];
    [self.dataClient setPostValue:[NSString stringWithFormat:@"%@",rangeStr]  forKey:@"range"];
    
    [self.dataClient setData:subData
                withFileName:fileId
              andContentType:[NSString stringWithFormat:@"%@",rangeStr]
                      forKey:@"filedata"];
    self.lastUploadBlockSize = range.length;
    [self.dataClient startAsynchronous];
}

/**
 *  发送文件步骤三：确认整个文件已完全传输
 *
 */
-(void)uploadConfirmFileWithServerFileID:(NSString*)fid length:(int)length checkCode:(NSString*)checkCode checkFlag:(int)checkFlag
                            compressFlag:(int)compressFlag encryptFlag:(int)encryptFlag {
    NSString *url=[NSString stringWithFormat:@"%@%@",MITI_IP,@"mServices!uploadComplete.action"];
    NSString *bodyStr = [NSString stringWithFormat:@"ua=%@&sss=%@&fid=%@&len=%d&checkCode=%@&checkFlag=%d&compressFlag=%d&encryptFlag=%d",
                         @"file.upconfirm",
                         [USERDEFAULTS objectForKey:@"session_id"],
                         fid,
                         length,
                         checkCode,
                         checkFlag,
                         compressFlag,
                         encryptFlag];
    self.client = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    self.client.tag = UploadTypeConfirm;
    self.client.delegate = self;
    self.client.timeOutSeconds = TIMEOUT_INTERVAL;
    [self.client addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [self.client appendPostData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    [self.client setRequestMethod:POST];
    [self.client startAsynchronous];
}

/**
 *  步骤四：提交文件，存入数据库
 */
-(void)saveFileOnServerWithFileID:(NSString*)fileId {
    if ([[self.uploadInfo objectForKey:UPLOAD_FILE_TYPE] isEqualToString:MEDIA_FILE]) {
        NSString *url=[NSString stringWithFormat:@"%@%@",MITI_IP,@"mServices!saveNews.action"];
        NSString *bodyStr=[NSString stringWithFormat:@"ua=%@&sss=%@&fid=%@&len=%lu&origin=%@",
                           @"process.savemultimedia",
                           [USERDEFAULTS objectForKey:@"session_id"],
                           fileId,
                           (unsigned long)self.fileLength,
                           [self.uploadInfo objectForKey:UPLOAD_FILE_NAME]];
        self.client = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
        self.client.tag = UploadTypeSaveFile;
        self.client.delegate = self;
        self.client.timeOutSeconds = TIMEOUT_INTERVAL;
        [self.client addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        [self.client appendPostData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
        [self.client setRequestMethod:POST];
        [self.client startAsynchronous];
    } else if ([[self.uploadInfo objectForKey:UPLOAD_FILE_TYPE] isEqualToString:LOG_FILE]) {
        
    } else if ([[self.uploadInfo objectForKey:UPLOAD_FILE_TYPE] isEqualToString:XML_FILE]) {
        
    }
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    
}

















@end
