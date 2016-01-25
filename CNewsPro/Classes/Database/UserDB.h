//
//  UserDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@class User;
@interface UserDB : BasicDatabase

/**
 *  判断用户名和密码是否存在
 */
- (BOOL)getUserAndPassword:(NSString *)username password:(NSString *)password;

/**
 *  添加用户
 *
 */
- (NSInteger)addUser:(User *)user;


@end
