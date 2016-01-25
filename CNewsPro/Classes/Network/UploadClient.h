//
//  UploadClient.h
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadClient : NSObject

@property (nonatomic,assign) id delegate;

@property (nonatomic,assign) NSInteger currentIndexPath;

@property (nonatomic,assign) BOOL paused;

@property (nonatomic,assign) BOOL running;

@property (nonatomic,assign) float progress;

@property (nonatomic,assign) double beginUp;

@property (nonatomic,strong) NSMutableDictionary *uploadInfo;

@property (nonatomic,assign) NSInteger xmlOnly;

@property (nonatomic,copy) NSString *serverFileID;    //记录服务端传回的ServerFileID

@property (nonatomic,copy) NSString *xmlServerFileID;//记录xml回传id

- (instancetype)initWithDelegate:(id)aDelegate info:(id)uploadInfo;

/**
 *  开始上传
 */
-(void)startUpload;

/**
 *  暂停上传
 */
-(void)pauseUpload;

/**
 *  恢复上传
 */
-(void)continueUpload;

/**
 *  取消上传
 */
-(void)cancelUpload;




@end
