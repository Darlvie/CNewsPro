//
//  LanguageDB.m
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "LanguageDB.h"
#import "Language.h"

@implementation LanguageDB

- (NSInteger)addLanguageList:(NSMutableArray *)LanguageList {
    if ([self openDatabase] == FALSE) {
        return -1;
    }
    //开启事务
    [self beginTransaction];
    
    NSString *sql = @"INSERT INTO Language (l_id,code,name,language,`order`)VALUES (?,?,?,?,?)";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    int row = 0;
    for (NSInteger i = 0; i < LanguageList.count; i++) {
        Language *lan = [LanguageList objectAtIndex:i];
        sqlite3_bind_text(statement, 1, [lan.l_id UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [lan.code UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [lan.name UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 4, [lan.language UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 5, [lan.order UTF8String], -1, NULL);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database");
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return -1;
        }
        sqlite3_reset(statement);
        row ++;
    }
    sqlite3_finalize(statement);
    
    [self commitTransaction];
    sqlite3_close(database);
    return row;
}

//查看语种列表
- (NSMutableArray*)getLanguageList {
    NSMutableArray *languageList = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]==FALSE) {
        return nil;
    }
    
    NSString *sql = @"SELECT * FROM Language order by l_id";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    while (sqlite3_step(statement)==SQLITE_ROW) {
        Language *language=[[Language alloc] init];
        
        language.l_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        language.code = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        language.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        language.language = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        language.order = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        [languageList addObject:language];
        
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return languageList;
}

- (BOOL)deleteAll {
    if ([self openDatabase] == FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"DELETE FROM Language";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to prepare");
        return FALSE;
    }
    
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
