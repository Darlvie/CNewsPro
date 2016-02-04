//
//  AccessoriesDB.m
//  CNewsPro
//
//  Created by hooper on 1/22/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "AccessoriesDB.h"
#import "Accessories.h"

@implementation AccessoriesDB

- (NSMutableArray *)getAccessoriesListByMId:(NSString *)m_id {
    NSMutableArray *accessList = [[NSMutableArray alloc] init];
    if ([self openDatabase] == FALSE) {
        return nil;
    }
    
    NSString *sql = @"SELECT * FROM Accessories where m_id = ?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    
    sqlite3_bind_text(statement, 1, [m_id UTF8String], -1, NULL);
    while (sqlite3_step(statement) == SQLITE_ROW) {
        Accessories *access = [[Accessories alloc] init];
        access.a_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        access.m_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        access.createTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        access.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        access.desc = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        access.size = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
        access.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
        access.originName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
        access.info = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
        [accessList addObject:access];
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return accessList;
}

- (BOOL)updateAccessories:(Accessories*)access {
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"UPDATE Accessories SET m_id=?,createtime=?,title=?,desc=?,size=?,type=?,originalName=?,info=? Where a_id=?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to prepare");
        return FALSE;
    }
    
    //绑定参数
    
    sqlite3_bind_text(statement, 1, [access.m_id UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [access.createTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 3, [access.title UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 4, [access.desc UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 5, [access.size UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 6, [access.type UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 7, [access.originName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 8, [access.info UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 9, [access.a_id UTF8String], -1, NULL);
    
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

- (BOOL)deleteAccessoriesByID:(NSString *)access_id {
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"DELETE FROM Accessories WHERE a_id = ?";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error: failed to prepare");
        return FALSE;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1,[access_id UTF8String], -1, NULL);
    
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

- (NSInteger)addAccessories:(Accessories*)access {
    if ([self openDatabase]==FALSE) {
        return -1;
    }
    
    NSString *sql = @"INSERT INTO Accessories (m_id,createtime,title,desc,size,type,originalName,info,url,a_id)VALUES (?,?,?,?,?,?,?,?,?,?)";
  
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [access.m_id UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [access.createTime UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 3, [access.title UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 4, [access.desc UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 5, [access.size UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 6, [access.type UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 7, [access.originName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 8, [access.info UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 9, [access.originName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 10,[access.a_id UTF8String], -1, NULL);
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

@end
