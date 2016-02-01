//
//  NewsCategoryDB.m
//  CNewsPro
//
//  Created by zyq on 16/1/25.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "NewsCategoryDB.h"
#import "NewsCategory.h"

@implementation NewsCategoryDB

- (NSInteger)addNewsCategoryList:(NSMutableArray *)NewsCategoryList {
    if ([self openDatabase]==FALSE) {
        return -1;
    }
    
    //开启事务
    [self beginTransaction];
    
    NSString *sql = @"INSERT INTO NewsCategory(code,name,language)VALUES (?,?,?)";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    int row=0;
    for (NSInteger i=0; i<[NewsCategoryList count]; i++)
    {
        NewsCategory *newsCategory=[NewsCategoryList objectAtIndex:i];
        //绑定参数
        sqlite3_bind_text(statement, 1, [newsCategory.code UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [newsCategory.name UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [newsCategory.language UTF8String], -1, NULL);
        
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


//按id顺序查看稿件分类列表
- (NSMutableArray*)getNewsCategoryListBySupernewsCategory:(NewsCategory*)newsCategory Type:(NSInteger)newsCategoryType {
    
    NSMutableArray *newsCategoryList = [[NSMutableArray alloc] init];
    NSString *string = nil;
    if (newsCategoryType) {
        string = [newsCategory.code  stringByAppendingString:@"___"];
    }
    else {
        string = [newsCategory.code  stringByAppendingString:@"___"];
    }
    if ([self openDatabase]==FALSE) {
        return nil;
    }

    NSString *sql = @"SELECT * FROM NewsCategory where  language like 'zh-CN' and code like ?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    //绑定参数
    sqlite3_bind_text(statement, 1,[string UTF8String], -1, NULL);
    while (sqlite3_step(statement)==SQLITE_ROW) {
        NewsCategory *newsCategory=[[NewsCategory alloc] init];
        
        newsCategory.nc_id = sqlite3_column_int(statement, 0);
        newsCategory.code =[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        newsCategory.name=[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        newsCategory.language=[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        
        [newsCategoryList addObject:newsCategory];
        
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return newsCategoryList;
}

- (BOOL)deleteAll {
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"DELETE FROM NewsCategory";
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
