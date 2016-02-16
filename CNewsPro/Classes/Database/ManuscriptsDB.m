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
- (BOOL)setManuscriptStatus:(NSString *)manuscriptStatus mId:(NSString *)m_id {
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
    NSString *sql = @"SELECT * FROM Manuscripts where loginname=? and manuscriptsStatus=? ";
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
    
    NSString *sql = @"UPDATE Manuscripts SET newsid=?,manuscriptsStatus=? Where m_id=?";
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

//更新拆分后的稿件标题（附件如果有标题，需要进行拼接）
- (BOOL)updateManuscriptTitle:(NSString *)title content:(NSString *)content m_id:(NSString *)m_id {
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    NSString *sql = @"update Manuscripts set title=?,contents=? WHERE m_id = ?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to prepare");
        return FALSE;
    }
    //绑定参数
    sqlite3_bind_text(statement, 1, [title UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [content UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 3, [m_id UTF8String], -1, NULL);
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

//根据稿件的guid，更新稿件发送成功的时间
- (BOOL)updateSendToTime:(NSString *)senttime m_id:(NSString *)m_id {
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    NSString *sql = @"UPDATE Manuscripts SET senttime=? Where m_id=?";
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


- (Manuscripts *)getManuscriptById:(NSString *)m_id {
    Manuscripts *manuscript = [[Manuscripts alloc] init ];
    if ([self openDatabase] == FALSE) {
        return nil;
    }
    
    NSString *sql = @"SELECT * FROM Manuscripts where m_id=? ";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    //绑定参数
    sqlite3_bind_text(statement, 1, [m_id UTF8String], -1, NULL);
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        [self manuscriptORM:statement manuscript:manuscript];
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return manuscript;
}

- (NSInteger)addManuScript:(Manuscripts *)manuScript {
    if ([self openDatabase]==FALSE) {
        return -1;
    }
    
    NSString *sql=@"INSERT INTO Manuscripts (m_id,loginname,createid,releid,newsid,title,title3T,usernameC,usernameE,groupnameC,groupcode,groupnameE,newstype,newstypeID,comefromDept,comefromDeptID,provtype,provtypeid,doctype,doctypeID,keywords,language,languageID,priority,priorityID,sendarea,happenplace,reportplace,address,addressID,comment,is3Tnews,createtime,rejecttime,reletime,senttime,rereletime,reviewstatus,region,regionID,contents,contents3T,receivetime,newsIDBacktime,manuscriptsStatus,location,author) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    //绑定参数
    
    sqlite3_bind_text(statement, 1, [manuScript.m_id UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [[USERDEFAULTS objectForKey:LOGIN_NAME] UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 3, [manuScript.createId UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 4, [manuScript.releId UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 5, [manuScript.newsId UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 6, [manuScript.title UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 7, [manuScript.title3T UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 8, [manuScript.userNameC UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 9, [manuScript.userNameE UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 10, [manuScript.groupNameC UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 11, [manuScript.groupCode UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 12, [manuScript.groupNameE UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 13, [manuScript.newsType UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 14, [manuScript.newsTypeID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 15, [manuScript.mTemplate.comeFromDept UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 16, [manuScript.mTemplate.comeFromDeptID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 17, [manuScript.mTemplate.provType UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 18, [manuScript.mTemplate.provTypeid UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 19, [manuScript.mTemplate.docType UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 20, [manuScript.mTemplate.docTypeID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 21, [manuScript.mTemplate.keywords UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 22, [manuScript.mTemplate.language UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 23, [manuScript.mTemplate.languageID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 24, [manuScript.mTemplate.priority UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 25, [manuScript.mTemplate.priorityID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 26, [manuScript.mTemplate.sendArea UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 27, [manuScript.mTemplate.happenPlace UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 28, [manuScript.mTemplate.reportPlace UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 29, [manuScript.mTemplate.address UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 30, [manuScript.mTemplate.addressID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 31, [manuScript.comment UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 32, [manuScript.mTemplate.is3Tnews UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 33, [manuScript.createTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 34, [manuScript.rejectTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 35, [manuScript.releTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 36, [manuScript.sentTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 37, [manuScript.releTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 38, [manuScript.mTemplate.reviewStatus UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 39, [manuScript.mTemplate.region UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 40, [manuScript.mTemplate.regionID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 41, [manuScript.contents UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 42, [manuScript.contents3T UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 43, [manuScript.receiveTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 44, [manuScript.newsIDBackTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 45, [manuScript.manuscriptsStatus UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 46, [manuScript.location UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 47, [manuScript.mTemplate.author UTF8String], -1, NULL);
    
    success = sqlite3_step(statement);
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to insert into the database");
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return -1;
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return sqlite3_last_insert_rowid(database);
}


- (NSInteger)updateManuscript:(Manuscripts *)manuScript {
    if ([self openDatabase]==FALSE) {
        return -1;
    }
    
    NSString *sql=@"UPDATE Manuscripts SET  loginname = ?, createid = ?, releid = ?, newsid = ?, title = ?, title3T = ?, usernameC = ?, usernameE = ?, groupnameC = ?, groupcode = ?, groupnameE = ?, newstype = ?, newstypeID = ?, comefromDept = ?, comefromDeptID = ?, provtype = ?, provtypeid = ?, doctype = ?, doctypeID = ?, keywords = ?, language = ?, languageID = ?, priority = ?, priorityID = ?, sendarea = ?, happenplace = ?, reportplace = ?, address = ?, addressID = ?, comment = ?, is3Tnews = ?, createtime = ?, rejecttime = ?, reletime = ?, senttime = ?, rereletime = ?, reviewstatus = ?, region = ?, regionID = ?, contents = ?, contents3T = ?, receivetime = ?, newsIDBacktime = ?, manuscriptsStatus = ? ,location=?,author=? WHERE  m_id = ?";
    
    
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [[USERDEFAULTS objectForKey:LOGIN_NAME] UTF8String], -1, NULL);//liuwei 0702
    sqlite3_bind_text(statement, 2, [manuScript.createId UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 3, [manuScript.releId UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 4, [manuScript.newsId UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 5, [manuScript.title UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 6, [manuScript.title3T UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 7, [manuScript.userNameC UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 8, [manuScript.userNameE UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 9, [manuScript.groupNameC UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 10, [manuScript.groupCode UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 11, [manuScript.groupNameE UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 12, [manuScript.newsType UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 13, [manuScript.newsTypeID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 14, [manuScript.mTemplate.comeFromDept UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 15, [manuScript.mTemplate.comeFromDeptID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 16, [manuScript.mTemplate.provType UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 17, [manuScript.mTemplate.provTypeid UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 18, [manuScript.mTemplate.docType UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 19, [manuScript.mTemplate.docTypeID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 20, [manuScript.mTemplate.keywords UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 21, [manuScript.mTemplate.language UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 22, [manuScript.mTemplate.languageID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 23, [manuScript.mTemplate.priority UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 24, [manuScript.mTemplate.priorityID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 25, [manuScript.mTemplate.sendArea UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 26, [manuScript.mTemplate.happenPlace UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 27, [manuScript.mTemplate.reportPlace UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 28, [manuScript.mTemplate.address UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 29, [manuScript.mTemplate.addressID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 30, [manuScript.comment UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 31, [manuScript.mTemplate.is3Tnews UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 32, [manuScript.createTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 33, [manuScript.rejectTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 34, [manuScript.releTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 35, [manuScript.sentTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 36, [manuScript.releTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 37, [manuScript.mTemplate.reviewStatus UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 38, [manuScript.mTemplate.region UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 39, [manuScript.mTemplate.regionID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 40, [manuScript.contents UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 41, [manuScript.contents3T UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 42, [manuScript.receiveTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 43, [manuScript.newsIDBackTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 44, [manuScript.manuscriptsStatus UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 45, [manuScript.location UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 46, [manuScript.mTemplate.author UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 47, [manuScript.m_id UTF8String], -1, NULL);
    
    success = sqlite3_step(statement);
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to insert into the database");
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return -1;
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return YES;
}


- (NSMutableArray *)getManuscriptListByStatus:(NSString *)userName status:(NSString *)mStatus pageNO:(int)pageNO pageSize:(int)pageSize{
    
    NSMutableArray *ManuScriptList = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]==FALSE) {
        return nil;
    }
    NSString *sql=@"";
    if ([mStatus isEqualToString:MANUSCRIPT_STATUS_SENT]) {
        sql = @"SELECT * FROM Manuscripts where loginname=? and manuscriptsStatus=? order by senttime Desc limit ?,?";//已发稿件按照发稿时间进行排序
    }else {
        sql = @"SELECT * FROM Manuscripts where loginname=? and manuscriptsStatus=? order by createtime Desc limit ?,?";
    }
    
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [userName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [mStatus UTF8String], -1, NULL);
    sqlite3_bind_int(statement, 3, pageNO*pageSize);
    sqlite3_bind_int(statement, 4, pageSize);

    
    while (sqlite3_step(statement)==SQLITE_ROW) {
        ScriptItem *manuscript = [ScriptItem scriptItem];
        
        [self manuscriptORM:statement manuscript:manuscript];
        if( ![manuscript.m_id isEqualToString:@""] )
            [ManuScriptList addObject:manuscript];
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return ManuScriptList;
}


- (NSInteger)getNumberOfManuscriptsByStatus:(NSString *)userName status:(NSString *)mStatus {
    if ([self openDatabase]==FALSE) {
        return -1;
    }
    
    NSString *sql = @"SELECT count(*) FROM Manuscripts where loginname=? and manuscriptsStatus=?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return -1;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [userName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [mStatus UTF8String], -1, NULL);

    NSInteger totalNumber=0;
    while (sqlite3_step(statement)==SQLITE_ROW) {
        totalNumber = sqlite3_column_int(statement,0);
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);

    return totalNumber;
}

//删除稿件   :  需要加入本地多媒体文件的删除
- (BOOL)deleteManuscript:(NSString *)m_id
{
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"DELETE FROM Manuscripts WHERE m_id = ?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to prepare");
        return FALSE;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [m_id UTF8String], -1, NULL);
    
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













@end
