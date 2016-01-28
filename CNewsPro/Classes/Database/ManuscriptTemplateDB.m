//
//  ManuscriptTemplateDB.m
//  CNewsPro
//
//  Created by zyq on 16/1/22.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "ManuscriptTemplateDB.h"
#import "ManuscriptTemplate.h"

@implementation ManuscriptTemplateDB

//获取系统稿签模板 即issystemoriginal != normal的稿签
- (NSMutableArray *)getSystemTemplate:(NSString *)userName type:(NSString *)tagType {
    NSMutableArray *manuscriptList = [[NSMutableArray alloc] init];
    if ([self openDatabase] == FALSE) {
        return nil;
    }
    NSString *sql = @"SELECT * FROM ManuScriptTemplate where loginname=? and issystemoriginal<>? order by CreateTime";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    
    sqlite3_bind_text(statement, 1, [userName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [tagType UTF8String], -1, NULL);
   
    while (sqlite3_step(statement) == SQLITE_ROW) {
        ManuscriptTemplate *manuscriptTemplate = [[ManuscriptTemplate alloc] init];
        manuscriptTemplate.mt_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        manuscriptTemplate.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        manuscriptTemplate.loginName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        manuscriptTemplate.comeFromDept = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        manuscriptTemplate.comeFromDeptID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        manuscriptTemplate.region = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,5)];
        manuscriptTemplate.regionID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,6)];
        manuscriptTemplate.docType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,7)];
        manuscriptTemplate.docTypeID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,8)];
        manuscriptTemplate.provType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,9)];
        manuscriptTemplate.provTypeid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,10)];
        manuscriptTemplate.keywords = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,11)];
        manuscriptTemplate.language = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,12)];
        manuscriptTemplate.languageID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,13)];
        manuscriptTemplate.priority = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,14)];
        manuscriptTemplate.priorityID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,15)];
        manuscriptTemplate.sendArea = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,16)];
        manuscriptTemplate.happenPlace = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,17)];
        manuscriptTemplate.reportPlace = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,18)];
        manuscriptTemplate.address = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,19)];
        manuscriptTemplate.addressID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,20)];
        manuscriptTemplate.is3Tnews = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,21)];
        manuscriptTemplate.isDefault = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,22)];
        manuscriptTemplate.createTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,23)];
        manuscriptTemplate.reviewStatus = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,24)];
        manuscriptTemplate.defaultTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,25)];
        manuscriptTemplate.defaultContents = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,26)];
        manuscriptTemplate.isSystemOriginal = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,27)];
        manuscriptTemplate.author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,28)];
        [manuscriptList addObject:manuscriptTemplate];
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return manuscriptList;
}

- (NSInteger)addManuscriptTemplate:(ManuscriptTemplate *)mtemplate {
    if ([self openDatabase] == FALSE) {
        return -1;
    }
    
    NSString *sql = @"INSERT INTO ManuscriptTemplate (mt_id,name,loginname,comefromDept,comefromDeptID,region,regionID,doctype,doctypeID,provtype,provtypeid,keywords,language,languageID,priority,priorityID,sendarea,happenplace,reportplace,address,addressID,is3Tnews,isdefault,createtime,reviewstatus,defaulttitle,defaultcontents,issystemoriginal,author) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    sqlite3_bind_text(statement, 1, [mtemplate.mt_id UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [mtemplate.name UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 3, [mtemplate.loginName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 4, [mtemplate.comeFromDept UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 5, [mtemplate.comeFromDeptID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 6, [mtemplate.region UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 7, [mtemplate.regionID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 8, [mtemplate.docType UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 9, [mtemplate.docTypeID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 10, [mtemplate.provType UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 11, [mtemplate.provTypeid UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 12, [mtemplate.keywords UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 13, [mtemplate.language UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 14, [mtemplate.languageID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 15, [mtemplate.priority UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 16, [mtemplate.priorityID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 17, [mtemplate.sendArea UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 18, [mtemplate.happenPlace UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 19, [mtemplate.reportPlace UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 20, [mtemplate.address UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 21, [mtemplate.addressID UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 22, [mtemplate.is3Tnews UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 23, [mtemplate.isDefault UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 24, [mtemplate.createTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 25, [mtemplate.reviewStatus UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 26, [mtemplate.defaultTitle UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 27, [mtemplate.defaultContents UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 28, [mtemplate.isSystemOriginal UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 29, [mtemplate.author UTF8String], -1, NULL);
    
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

//获取默认稿签
//获取稿签模板
- (ManuscriptTemplate *)getDefaultManuscriptTemplate:(NSString *)type LoginName:(NSString *)loginName {
    if ([self openDatabase]==FALSE) {
        return nil;
    }
    ManuscriptTemplate *manuscriptTemplate = [[ManuscriptTemplate alloc] init];
    
    NSString *sql = @"SELECT * FROM ManuScriptTemplate where isdefault=1 and loginname=?";
    //根据传入的类型来判断取哪个默认稿签
    if( [type isEqualToString:MANUSCRIPT_TEMPLATE_TYPE] )
        sql =  @"SELECT * FROM ManuScriptTemplate where isdefault=1 and loginname=? and issystemoriginal=?";
    else {
        sql =  @"SELECT * FROM ManuScriptTemplate where loginname=? and issystemoriginal=?";
    }
    
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [loginName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [type UTF8String], -1, NULL);
    
    while (sqlite3_step(statement)==SQLITE_ROW) {
        
        manuscriptTemplate.mt_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        manuscriptTemplate.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        manuscriptTemplate.loginName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        manuscriptTemplate.comeFromDept = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        manuscriptTemplate.comeFromDeptID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        manuscriptTemplate.region = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,5)];
        manuscriptTemplate.regionID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,6)];
        manuscriptTemplate.docType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,7)];
        manuscriptTemplate.docTypeID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,8)];
        manuscriptTemplate.provType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,9)];
        manuscriptTemplate.provTypeid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,10)];
        manuscriptTemplate.keywords = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,11)];
        manuscriptTemplate.language = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,12)];
        manuscriptTemplate.languageID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,13)];
        manuscriptTemplate.priority = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,14)];
        manuscriptTemplate.priorityID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,15)];
        manuscriptTemplate.sendArea = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,16)];
        manuscriptTemplate.happenPlace = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,17)];
        manuscriptTemplate.reportPlace = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,18)];
        manuscriptTemplate.address = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,19)];
        manuscriptTemplate.addressID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,20)];
        manuscriptTemplate.is3Tnews = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,21)];
        manuscriptTemplate.isDefault = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,22)];
        manuscriptTemplate.createTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,23)];
        manuscriptTemplate.reviewStatus = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,24)];
        manuscriptTemplate.defaultTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,25)];
        manuscriptTemplate.defaultContents = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,26)];
        manuscriptTemplate.isSystemOriginal = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,27)];
        manuscriptTemplate.author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,28)];
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return manuscriptTemplate;
}












@end
