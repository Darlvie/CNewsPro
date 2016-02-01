//
//  EmployeeSendToAddressDB.m
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "EmployeeSendToAddressDB.h"
#import "EmployeeSendToAddress.h"

@implementation EmployeeSendToAddressDB

- (NSInteger)addESTAddress:(EmployeeSendToAddress *)estAddress {
    if ([self openDatabase] == FALSE) {
        return -1;
    }
    
    NSString *sql = @"INSERT INTO EmployeeSendToAddress (loginname,code,`order`,language,name,type)VALUES (?,?,?,?,?,?)";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [estAddress.loginName UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 2, [estAddress.code UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 3, [estAddress.order UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 4, [estAddress.language UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 5, [estAddress.name UTF8String], -1, NULL);
    sqlite3_bind_text(statement, 6, [estAddress.type UTF8String], -1, NULL);
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

- (NSMutableArray *)getESTAddressListLoginName:(NSString *)loginName {
    NSMutableArray *estaList = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]==FALSE) {
        return nil;
    }
    NSString *sql = @"SELECT * FROM EmployeeSendToAddress where loginname = ? order by esa_id";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }
    
    //绑定参数
    sqlite3_bind_text(statement, 1, [loginName UTF8String],-1,NULL);
    
    while (sqlite3_step(statement)==SQLITE_ROW) {
        EmployeeSendToAddress *esta=[[EmployeeSendToAddress alloc] init];
        
        esta.esa_id = sqlite3_column_int(statement, 0);
        esta.loginName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        esta.code = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        esta.order = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        esta.language = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        esta.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
        esta.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
        
        [estaList addObject:esta];        
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return estaList;
}


- (BOOL)deleteAll{
    if ([self openDatabase]==FALSE) {
        return FALSE;
    }
    
    NSString *sql = @"DELETE FROM EmployeeSendToAddress";
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
