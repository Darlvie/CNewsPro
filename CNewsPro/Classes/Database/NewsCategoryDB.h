//
//  NewsCategoryDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@class NewsCategory;
@interface NewsCategoryDB : BasicDatabase

//批量添加
- (NSInteger)addNewsCategoryList:(NSMutableArray*)NewsCategoryList;

//按id顺序查看稿件分类列表
- (NSMutableArray *)getNewsCategoryListBySupernewsCategory:(NewsCategory*)newsCategory Type:(NSInteger)newsCategoryType;

- (BOOL)deleteAll;

@end
