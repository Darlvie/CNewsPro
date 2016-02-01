//
//  NewsPriorityDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface NewsPriorityDB : BasicDatabase

- (NSInteger)addPriorityList:(NSMutableArray*)provideList;

- (BOOL)deleteAll;

//按id顺序查看稿件优先级列表
- (NSMutableArray *)getNewsPriorityList;

@end
