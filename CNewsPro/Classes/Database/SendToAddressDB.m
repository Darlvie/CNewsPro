//
//  SendToAddressDB.m
//  CNewsPro
//
//  Created by hooper on 1/23/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "SendToAddressDB.h"
#import "SendToAddress.h"

@implementation SendToAddressDB

//查看发稿地址列表
- (NSMutableArray *)getSendToAddressList {
    
    NSMutableArray *sendToAddressList = [[NSMutableArray alloc] init];
    if ([self openDatabase]==FALSE) {
        return nil;
    }
    
    NSString *sql = @"SELECT * FROM SendToAddress where language like 'zh-CHS' order by [order]";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare select",success);
        return nil;
    }

    while (sqlite3_step(statement) == SQLITE_ROW) {
        SendToAddress *sendToAddress = [[SendToAddress alloc] init];
        sendToAddress.code = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        sendToAddress.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        sendToAddress.language = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        sendToAddress.order = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        
        [sendToAddressList addObject:sendToAddress];
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return sendToAddressList;
}

//批量添加
- (NSInteger)addSendAddressList:(NSMutableArray *)sendAddressList {
    if ([self openDatabase]==FALSE) {
        return -1;
    }
    //开启事务
    [self beginTransaction];
    
    NSString *sql = @"INSERT INTO SendToAddress (code,name,language,`order`)VALUES (?,?,?,?)";
    sqlite3_stmt *statement = nil;
    int success = [self prepareSQL:sql SQLStatement:&statement];
    if (success != SQLITE_OK) {
        NSLog(@"Error:%d failed to prepare insert",success);
        return -1;
    }
    
    int row = 0;
    for (int i = 0; i < sendAddressList.count; i++) {
        SendToAddress *sendToAddress = [sendAddressList objectAtIndex:i];
        sqlite3_bind_text(statement, 1, [sendToAddress.code UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [sendToAddress.name UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [sendToAddress.language UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 4, [sendToAddress.order UTF8String], -1, NULL);
        
        success = sqlite3_step(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database");
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return -1;
        }
        //重新初始化该statement对象绑定的变量
        sqlite3_reset(statement);
        row ++;
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
    
    NSString *sql = @"DELETE FROM SendToAddress";
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
