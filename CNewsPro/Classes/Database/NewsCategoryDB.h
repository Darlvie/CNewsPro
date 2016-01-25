//
//  NewsCategoryDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface NewsCategoryDB : BasicDatabase

//批量添加
- (NSInteger)addNewsCategoryList:(NSMutableArray*)NewsCategoryList;

- (BOOL)deleteAll;

@end
