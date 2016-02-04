//
//  AccessoriesDB.h
//  CNewsPro
//
//  Created by hooper on 1/22/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@class Accessories;
@interface AccessoriesDB : BasicDatabase

//根据m_id获得稿件对应的附件列表
- (NSMutableArray*)getAccessoriesListByMId:(NSString*)m_id;

- (BOOL)updateAccessories:(Accessories*)access;

- (BOOL)deleteAccessoriesByID:(NSString *)access_id;

- (NSInteger)addAccessories:(Accessories*)access;

@end
