//
//  Manuscripts.m
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "Manuscripts.h"
#import "ManuscriptTemplate.h"

@implementation Manuscripts

- (instancetype)init {
    if (self = [super init]) {
        self.
        m_id=@"";
        self.createId=@"";
        self.releId=@"";
        self.newsId=@"";
        self.title=@"";
        self.title3T=@"";
        self.userNameC=@"";
        self.userNameE=@"";
        self.groupCode=@"";
        self.groupNameC=@"";
        self.groupNameE=@"";
        self.newsType=@"";
        self.newsTypeID=@"";
        self.comment=@"";
        self.rejectTime=@"";
        self.releTime=@"";
        self.sentTime = @"";
        self.rereleTime = @"";
        self.contents = @"";
        self.contents3T = @"";
        self.receiveTime = @"";
        self.newsIDBackTime=@"";
        self.manuscriptsStatus=@"";
        self.mTemplate = [[ManuscriptTemplate alloc]init];
        self.location = @"";
        self.createTime = @"";
    }
    return self;
}

@end
