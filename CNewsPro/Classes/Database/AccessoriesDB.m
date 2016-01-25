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


@end
