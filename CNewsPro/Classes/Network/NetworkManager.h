//
//  NetworkManager.h
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

@interface NetworkManager : NSObject

@property (nonatomic,strong) ASINetworkQueue *commonQueue;
@property (nonatomic,strong) ASINetworkQueue *pictureQueue;
@property (nonatomic,strong) NSMutableArray *picUrlArray;

+ (instancetype)sharedManager;

/**
 *  请求数据
 *
 */
- (void)requestDataWithDelegate:(id)delegate info:(id)requestInfo;

/**
 *  取消某个对象的所有数据
 */
- (void)cancelRequestForDelegate:(id)delegate;

@end
