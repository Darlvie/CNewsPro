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

@end
