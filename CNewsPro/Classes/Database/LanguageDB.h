//
//  LanguageDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface LanguageDB : BasicDatabase
//批量添加
- (NSInteger)addLanguageList:(NSMutableArray*)LanguageList;

//查看语种列表
- (NSMutableArray *)getLanguageList;

- (BOOL)deleteAll;


@end
