//
//  NewTypeDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface NewTypeDB : BasicDatabase

- (NSInteger)addNewsTypeList:(NSMutableArray*)NewsTypeList;//批量添加

- (BOOL)deleteAll;


@end
