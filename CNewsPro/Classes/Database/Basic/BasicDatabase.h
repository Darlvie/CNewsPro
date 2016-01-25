//
//  BasicDatabase.h
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface BasicDatabase : NSObject {
    sqlite3 *database;
    NSString *path;
}

- (void)readyDatabase;

- (void)getPath;

+ (BasicDatabase *)sharedDB;

+ (void)relaseDatabase;

- (BOOL)openDatabase;

- (void)beginTransaction;

- (void)commitTransaction;

- (int)prepareSQL:(NSString *)sql SQLStatement:(sqlite3_stmt **)statement;

@end
