//
//  UserDB.m
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "UserDB.h"
#import "User.h"

@implementation UserDB


- (BOOL)getUserAndPassword:(NSString *)username password:(NSString *)password {
    if (![self openDatabase]) {
        return FALSE;
    }
    
    NSString *sql = @"select * from User where loginname=? and password=?";
    sqlite3_stmt *statement = nil;
    if ([self prepareSQL:sql SQLStatement:&statement] != SQLITE_OK) {
        return FALSE;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [username UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [password UTF8String], -1, NULL);
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return TRUE;
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return FALSE;
}

- (NSInteger)addUser:(User *)user {
    if ([self openDatabase] == FALSE) {
        return -1;
    }
    NSString *sql = @"INSERT INTO User (loginname,password) VALUES (?,?)";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    //绑定参数
    sqlite3_bind_text(statement, 1, [user.loginName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [user.password UTF8String], -1, NULL);
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
