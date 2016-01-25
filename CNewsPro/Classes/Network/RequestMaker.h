//
//  RequestMaker.h
//  CNewsPro
//
//  Created by zyq on 16/1/13.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestMaker : NSObject

/**
 *  同步登录请求
 */
+ (NSString *)syncLoginWithUerName:(NSString *)userName password:(NSString *)pwd;
/**
 *  保持会话
 */
+ (BOOL)keepAlive;

/**
 *  登录请求
 */
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate;

//获取当前版本号
+ (NSString *)getServerVersion;

//get请求同步
+ (NSString *)syncGetUserInfo:(NSString*)sessionId loginName:(NSString*)loginName;


+ (BOOL)getUrlArry:(NSString *)defaultUrl;

//获取稿签
+ (void)getTemplate:(NSString *)loginName sessionid:(NSString *)sessionId delegate:(id)delegate;

@end
