//
//  AccessoriesDB.h
//  CNewsPro
//
//  Created by hooper on 1/22/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface AccessoriesDB : BasicDatabase

//根据m_id获得稿件对应的附件列表
- (NSMutableArray*)getAccessoriesListByMId:(NSString*)m_id;

@end
