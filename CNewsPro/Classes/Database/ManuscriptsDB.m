//
//  ManuscriptsDB.m
//  CNewsPro
//
//  Created by zyq on 16/1/21.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "ManuscriptsDB.h"
#import "ScriptItem.h"
#import "ManuscriptTemplate.h"

@implementation ManuscriptsDB

//恢复稿件   :  改变稿件状态
- (BOOL)setManuScriptStatus:(NSString *)manuscriptStatus mId:(NSString *)m_id {
    if ([self openDatabase] == FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"UPDATE Manuscripts SET manuscriptsStatus=? where m_id =?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to prepare");
        return FALSE;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [manuscriptStatus UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [m_id UTF8String], -1, NULL);
    
    success = sqlite3_step(statement);
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to delete record");
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return FALSE;
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return YES;
}

- (NSMutableArray *)getManuscriptsByStatus:(NSString *)userName status:(NSString *)mStatus {
    NSMutableArray *manuscriptList = [[NSMutableArray alloc] init];
    if ([self openDatabase] == FALSE) {
        return nil;
    }
    NSString *sql = @"SELECT * FROM ManuScripts where loginname=? and manuscriptsStatus=? ";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    sqlite3_bind_text(statement, 1, [userName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [mStatus UTF8String], -1, NULL);
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        ScriptItem *manuscript = [[ScriptItem alloc] init];
        [self manuscriptORM:statement manuscript:manuscript];
        if (![manuscript.m_id isEqualToString:@""]) {
            [manuscriptList addObject:manuscript];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return manuscriptList;
}

- (void)manuscriptORM:(sqlite3_stmt *)statement manuscript:(Manuscripts *)manuscript {
    manuscript.m_id = (sqlite3_column_text(statement, 0)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]:@"";
    manuscript.mTemplate.loginName = (sqlite3_column_text(statement, 1)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]:@"";
    manuscript.createId = (sqlite3_column_text(statement, 2)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]:@"";
    manuscript.releId = (sqlite3_column_text(statement, 3)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]:@"";
    manuscript.newsId = (sqlite3_column_text(statement, 4)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]:@"";
    manuscript.title = (sqlite3_column_text(statement, 5)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,5)]:@"";
    manuscript.title3T = (sqlite3_column_text(statement, 6)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,6)]:@"";
    manuscript.userNameC = (sqlite3_column_text(statement, 7)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,7)]:@"";
    manuscript.userNameE = (sqlite3_column_text(statement, 8)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,8)]:@"";
    manuscript.groupNameC = (sqlite3_column_text(statement, 9)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,9)]:@"";
    manuscript.groupCode = (sqlite3_column_text(statement, 10)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,10)]:@"";
    manuscript.groupNameE = (sqlite3_column_text(statement, 11)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,11)]:@"";
    manuscript.newsType = (sqlite3_column_text(statement, 12)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,12)]:@"";
    manuscript.newsTypeID = (sqlite3_column_text(statement, 13)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,13)]:@"";
    manuscript.mTemplate.comeFromDept = (sqlite3_column_text(statement, 14)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,14)]:@"";
    manuscript.mTemplate.comeFromDeptID = (sqlite3_column_text(statement, 15)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,15)]:@"";
    manuscript.mTemplate.provType = (sqlite3_column_text(statement, 16)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,16)]:@"";
    manuscript.mTemplate.provTypeid = (sqlite3_column_text(statement, 17)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,17)]:@"";
    manuscript.mTemplate.docType = (sqlite3_column_text(statement, 18)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,18)]:@"";
    manuscript.mTemplate.docTypeID = (sqlite3_column_text(statement, 19)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,19)]:@"";
    manuscript.mTemplate.keywords = (sqlite3_column_text(statement, 20)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,20)]:@"";
    manuscript.mTemplate.language = (sqlite3_column_text(statement, 21)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,21)]:@"";
    manuscript.mTemplate.languageID = (sqlite3_column_text(statement, 22)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,22)]:@"";
    manuscript.mTemplate.priority = (sqlite3_column_text(statement, 23)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,23)]:@"";
    manuscript.mTemplate.priorityID = (sqlite3_column_text(statement, 24)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,24)]:@"";
    manuscript.mTemplate.sendArea = (sqlite3_column_text(statement, 25)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,25)]:@"";
    manuscript.mTemplate.happenPlace = (sqlite3_column_text(statement, 26)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,26)]:@"";
    manuscript.mTemplate.reportPlace = (sqlite3_column_text(statement, 27)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,27)]:@"";
    manuscript.mTemplate.address = (sqlite3_column_text(statement, 28)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,28)]:@"";
    manuscript.mTemplate.addressID = (sqlite3_column_text(statement, 29)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,29)]:@"";
    manuscript.comment = (sqlite3_column_text(statement, 30)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,30)]:@"";
    manuscript.mTemplate.is3Tnews = (sqlite3_column_text(statement, 31)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,31)]:@"";
    manuscript.createTime = (sqlite3_column_text(statement, 32)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,32)]:@"";
    manuscript.rejectTime = (sqlite3_column_text(statement, 33)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,33)]:@"";
    manuscript.releTime = (sqlite3_column_text(statement, 34)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,34)]:@"";
    manuscript.sentTime = (sqlite3_column_text(statement, 35)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,35)]:@"";
    manuscript.rereleTime = (sqlite3_column_text(statement, 36)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,36)]:@"";
    manuscript.mTemplate.reviewStatus = (sqlite3_column_text(statement, 37)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,37)]:@"";
    manuscript.mTemplate.region = (sqlite3_column_text(statement, 38)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,38)]:@"";
    manuscript.mTemplate.regionID = (sqlite3_column_text(statement, 39)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,39)]:@"";
    manuscript.contents = (sqlite3_column_text(statement, 40)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,40)]:@"";
    manuscript.contents3T = (sqlite3_column_text(statement, 41)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,41)]:@"";
    manuscript.receiveTime = (sqlite3_column_text(statement, 42)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,42)]:@"";
    manuscript.newsIDBackTime = (sqlite3_column_text(statement, 43)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,43)]:@"";
    manuscript.manuscriptsStatus = (sqlite3_column_text(statement, 44)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,44)]:@"";
    manuscript.location = (sqlite3_column_text(statement, 45)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,45)]:@"";
    manuscript.mTemplate.author = (sqlite3_column_text(statement, 46)!=nil)? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,46)]:@"";
}


- (BOOL)updateManuscriptNewsIdAndStatus:(NSString *)newsId m_id:(NSString *)m_id scriptStatus:(NSString *)scriptStatus {
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"UPDATE ManuScripts SET newsid=?,manuscriptsStatus=? Where m_id=?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to prepare");
        return FALSE;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [newsId UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [scriptStatus UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 3, [m_id UTF8String], -1, NULL);
    
    success = sqlite3_step(statement);
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to update record");
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return FALSE;
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return YES;

}

//根据稿件的guid，更新稿件发送成功的时间
- (BOOL)updateSendToTime:(NSString *)senttime m_id:(NSString *)m_id {
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    NSString *sql = @"UPDATE ManuScripts SET senttime=? Where m_id=?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to prepare");
        return FALSE;
    }
    //绑定参数
    sqlite3_bind_text(statement, 1, [senttime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [m_id UTF8String], -1, NULL);
    
    success = sqlite3_step(statement);
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to update record");
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return FALSE;
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return YES;
}





























@end
