//
//  Utility.h
//  CNewsPro
//
//  Created by zyq on 16/1/13.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User,ManuscriptTemplate,Manuscripts,AuditNewsItem,Accessories;
@interface Utility : NSObject

@property (nonatomic,strong) NSArray *urlArray;
@property (nonatomic,strong) User *userInfo;

+ (instancetype)sharedSingleton;

/**
 *  检测网络是否畅通
 */
+ (BOOL)testConnection;

/**
 *  检测软件版本更新
 */
+ (BOOL)checkNewVersion;

/**
 *  校验当前程序版本是否符合发稿要求
 */
+ (BOOL)checkVersion;

/**
 *  同步获取用户信息
 */
+ (void)initializeUserInfo;

/**
 *  将程序退出时没有执行的待发任务重新放入队列
 */
+ (void)sendUnFinishedTaskToQueue;

/**
 *  从文件中读取用户信息
 */
+ (void)getUserInfoFromFile;

+ (NSString*)getLogTimeStamp;

+ (User *)getUserInfo;

+ (void)getUrlArray;

+ (NSUInteger)getFileLengthByPath:(NSString*)filePath;

+ (NSString*)getFileMD5ByPath:(NSString*)filePath;

+ (NSData *)subDataWithRange:(NSRange)range filePath:(NSString*)filePath;

//检测网络是否可用、服务器地址是否可用、版本是否符合发稿要求，以及稿件的稿签是否符合要求
+ (NSString *)serialCheckBeforeSendManu:(Manuscripts *)mcripts;

/**
 *  校验稿件稿签中的发送地址与该用户被允许的发送地址是否匹配
 *
 */
+ (BOOL)checkSendToAddress:(User *)userInfo manuscriptTemplate:(ManuscriptTemplate *)manuTemplate;

//发送前的数据准备：属性赋值和拆条
+ (NSMutableArray *)prepareToSendManuscript:(Manuscripts *)manuscript accessories:(NSMutableArray *)accessoriesArry userInfoFromServer:(User *)userInfo;

//拼接xml
+ (void)xmlPackage:(Manuscripts *)mscripts accessories:(Accessories *)accessories;

//检测稿签和稿件信息是否完整
+ (NSString *)checkInfoIsCompleted:(Manuscripts *)mcripts;

//解析审批列表数据
+ (NSMutableDictionary *)parseAuditNewsListFromData:(NSData *)data;

+ (AuditNewsItem *)parseAuditNewsItemFromData:(NSData *)data;

/**
 *  将服务器上的稿签同步到手机
 */
+ (void)getTemplate;

//读取暂存稿签文件路径
+ (NSString *)temporaryTemplateFilePath;

+ (NSString *)trimBlankSpace:(NSString *)inputStr;

/**
 *  生成随机UUID
 */
+ (NSString *)stringWithUUID;

@end
