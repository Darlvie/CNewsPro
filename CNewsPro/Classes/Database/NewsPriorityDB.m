//
//  NewsPriorityDB.m
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "NewsPriorityDB.h"
#import "NewsPriority.h"

@implementation NewsPriorityDB

- (NSInteger)addPriorityList:(NSMutableArray *)provideList {
    if ([self openDatabase]==FALSE) {
        return -1;
    }
    
    //开启事务
    [self beginTransaction];
    
    NSString *sql = @"INSERT INTO NewsPriority (code,name,language)VALUES (?,?,?)";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    int row=0;
    for (NSInteger i=0; i<[provideList count]; i++)
    {
        NewsPriority *newspriority=[provideList objectAtIndex:i];
        //绑定参数
        sqlite3_bind_text(statement, 1, [newspriority.code UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [newspriority.name UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [newspriority.language UTF8String], -1, NULL);
        //sqlite3_bind_int(statement, 4, newspriority.np_id);
        
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

//按id顺序查看稿件优先级列表
- (NSMutableArray *)getNewsPriorityList {
    
    NSMutableArray *newsPriorityList = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]==FALSE) {
        return nil;
    }
    
    NSString *sql = @"SELECT * FROM NewsPriority where language like 'zh-CN' order by np_id";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    while (sqlite3_step(statement)==SQLITE_ROW) {
        NewsPriority *newsPriority=[[NewsPriority alloc] init];
        
        newsPriority.np_id = sqlite3_column_int(statement, 0);
        newsPriority.code = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        newsPriority.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        newsPriority.language = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        
        [newsPriorityList addObject:newsPriority];
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return newsPriorityList;
}

- (BOOL)deleteAll {
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"DELETE FROM NewsPriority";
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
