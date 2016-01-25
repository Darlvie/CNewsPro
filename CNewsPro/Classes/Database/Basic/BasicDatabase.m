//
//  BasicDatabase.m
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

static NSString *kDBFileName = @"mc.db";

@implementation BasicDatabase

static BasicDatabase *sharedBD = nil;

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (BasicDatabase *)sharedDB {
    @synchronized(self) {
        if (sharedBD == nil) {
            sharedBD = [[BasicDatabase alloc] init];
        }
    }
    return sharedBD;
}

+ (void)relaseDatabase {
    @synchronized(self) {
        if (sharedBD) {
            sharedBD = nil;
        }
    }
}

#pragma mark - 准备数据库
- (void)readyDatabase {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    [self getPath];
    success = [fileManager fileExistsAtPath:path];
    if (success) {
        return;
    }
    
    NSString *defaultBDPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDBFileName];
    success = [fileManager copyItemAtPath:defaultBDPath toPath:path error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

#pragma mark - 获取数据库路径
- (void)getPath {
    NSString *docDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [docDirectory stringByAppendingPathComponent:kDBFileName];
}

#pragma mark - 数据库操作
- (BOOL)openDatabase {
    [self readyDatabase];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (int)prepareSQL:(NSString *)sql SQLStatement:(sqlite3_stmt **)statement {
    return sqlite3_prepare_v2(database, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, statement, NULL);
}

/**
 *  显示的开启一个事务
 */
- (void)beginTransaction {
    sqlite3_stmt* stmt2 = NULL;
    const char *beginSQL = "BEGIN TRANSACTION";
    if (sqlite3_prepare_v2(database,beginSQL,(int)strlen(beginSQL),&stmt2,NULL) != SQLITE_OK) {
        if (stmt2)
            sqlite3_finalize(stmt2);
            sqlite3_close(database);
            return;
        }
        
        if (sqlite3_step(stmt2) != SQLITE_DONE) {
            sqlite3_finalize(stmt2);
            sqlite3_close(database);
            return;
        }
    sqlite3_finalize(stmt2);
}

/**
 *  提交之前的事务
 */
- (void)commitTransaction {
    const char *commitSQL = "COMMIT";
    sqlite3_stmt *stmt4 = NULL;
    if (sqlite3_prepare_v2(database, commitSQL, (int)strlen(commitSQL), &stmt4, NULL) != SQLITE_OK) {
        if (stmt4) {
            sqlite3_finalize(stmt4);
        }
        sqlite3_close(database);
        return;
    }
    
    if (sqlite3_step(stmt4) != SQLITE_DONE) {
        sqlite3_finalize(stmt4);
        sqlite3_close(database);
        return;
    }
    sqlite3_finalize(stmt4);
}






@end
