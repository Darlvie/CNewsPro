//
//  ManuscriptsDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/21.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface ManuscriptsDB : BasicDatabase

- (BOOL)setManuScriptStatus:(NSString *)manuscriptStatus mId:(NSString *)m_id;

/**
 *  根据稿件状态，取出稿件列表（淘汰、已编等状态值）
 *
 */
- (NSMutableArray *)getManuscriptsByStatus:(NSString *)userName status:(NSString *)mStatus;

@end
