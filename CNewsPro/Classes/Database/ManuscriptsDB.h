//
//  ManuscriptsDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/21.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@class Manuscripts;
@interface ManuscriptsDB : BasicDatabase

- (BOOL)setManuscriptStatus:(NSString *)manuscriptStatus mId:(NSString *)m_id;

/**
 *  根据稿件状态，取出稿件列表（淘汰、已编等状态值）
 *
 */
- (NSMutableArray *)getManuscriptsByStatus:(NSString *)userName status:(NSString *)mStatus;

//根据稿件的guid,更新回传稿号及稿件的状态
- (BOOL)updateManuscriptNewsIdAndStatus:(NSString *)newsId m_id:(NSString *)m_id  scriptStatus:(NSString *)scriptStatus;

//更新拆分后的稿件标题（附件如果有标题，需要进行拼接）
- (BOOL)updateManuscriptTitle:(NSString *)title content:(NSString *)content m_id:(NSString *)m_id;

//根据稿件的guid，更新稿件发送成功的时间
- (BOOL)updateSendToTime:(NSString *)senttime m_id:(NSString *)m_id;

- (Manuscripts *)getManuscriptById:(NSString *)m_id;

- (NSInteger)addManuScript:(Manuscripts *)manuScript;

- (NSInteger)updateManuscript:(Manuscripts *)manuScript;

@end
