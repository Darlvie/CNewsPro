//
//  ServerAddress.h
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerAddress : NSObject

@property (nonatomic,assign) NSInteger sa_id;

@property (nonatomic,copy) NSString *code;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *language;

@property (nonatomic,copy) NSString *order;

@property (nonatomic,copy) NSString *autoSaveInterval;

@property (nonatomic,copy) NSString *deletePolicy;

@property (nonatomic,copy) NSString *filePackSize;

@property (nonatomic,copy) NSString *newsSendPolicy;

@property (nonatomic,copy) NSString *failurePolicy;

@property (nonatomic,copy) NSString *sendFileNum;

@property (nonatomic,copy) NSString *encryptPolicy;
@end
