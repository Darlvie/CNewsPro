//
//  NewTypeDB.m
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "NewTypeDB.h"
#import "NewsType.h"

@implementation NewTypeDB

- (NSInteger)addNewsTypeList:(NSMutableArray *)NewsTypeList {
    if ([self openDatabase] == FALSE) {
        return -1;
    }
    
    //开启事务
    [self beginTransaction];
    
    NSString *sql = @"INSERT INTO NewsType(code,name,language)VALUES (?,?,?)";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    int row=0;
    for (NSInteger i=0; i<[NewsTypeList count]; i++)
    {
        NewsType *newsType=[NewsTypeList objectAtIndex:i];
        //绑定参数
        sqlite3_bind_text(statement, 1, [newsType.code UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [newsType.name UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [newsType.language UTF8String], -1, NULL);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database");
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return -1;
        }
        //重新初始化该statement对象绑定的变量
        sqlite3_reset(statement);
        row++;
    }
    sqlite3_finalize(statement);
    
    //执行事务
    [self commitTransaction];
    sqlite3_close(database);

    return row;
}

- (BOOL)deleteAll {
    if ([self openDatabase] == FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"DELETE FROM NewsType";
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
