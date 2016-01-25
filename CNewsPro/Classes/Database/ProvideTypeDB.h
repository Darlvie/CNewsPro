//
//  ProvideTypeDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface ProvideTypeDB : BasicDatabase

- (NSInteger)addProvideList:(NSMutableArray*)provideList;

- (BOOL)deleteAll;

@end
