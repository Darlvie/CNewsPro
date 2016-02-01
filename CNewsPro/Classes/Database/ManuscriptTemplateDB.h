//
//  ManuscriptTemplateDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/22.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@class ManuscriptTemplate;
@interface ManuscriptTemplateDB : BasicDatabase

- (NSMutableArray *)getSystemTemplate:(NSString *)userName type:(NSString *)tagType;

- (NSInteger)addManuscriptTemplate:(ManuscriptTemplate *)mtemplate;

- (ManuscriptTemplate *)getDefaultManuscriptTemplate:(NSString *)type LoginName:(NSString *)loginName;

- (NSMutableArray *)getManuScriptTemplate:(NSString *)userName type:(NSString *)tagType;

- (NSInteger)updateManuscriptTemplate:(ManuscriptTemplate *)mTemplate;

- (BOOL)deleteManuScriptTemplate:(NSString *)mt_id;

//获取全部稿签模板
- (NSMutableArray *)getAllTemplate:(NSString *)userName;




@end
