//
//  ServerAddressDB.m
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "ServerAddressDB.h"
#import "ServerAddress.h"

@implementation ServerAddressDB

- (ServerAddress *)getDefaultServer {
    if (![self openDatabase]) {
        return nil;
    }
    
    NSString *sql = @"SELECT * FROM ServerAddress order by sa_id limit 0,1";
    sqlite3_stmt *statement = nil;
    
    if ([self prepareSQL:sql SQLStatement:&statement] != SQLITE_OK) {
        NSLog(@"Error:failed to prepare select");
        return nil;
    }
    
    ServerAddress *sAddress = [[ServerAddress alloc] init];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        sAddress.sa_id = sqlite3_column_int(statement, 0);
        sAddress.code = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        sAddress.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        sAddress.language = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return sAddress;
}

@end
