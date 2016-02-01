//
//  AuditNewsItem.h
//  CNewsPro
//
//  Created by hooper on 1/31/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuditNewsItem : NSObject

@property (nonatomic,copy) NSString *anAbstract;//导语2
@property (nonatomic,assign) NSInteger auditNewsId;//id
@property (nonatomic,copy) NSString *author;//作者
@property (nonatomic,copy) NSString *channel;//栏目
@property (nonatomic,copy) NSString *content;//内容
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *status;//状态
@property (nonatomic,copy) NSString *title;//标题
@property (nonatomic,copy) NSString *videoSrc;

@end
