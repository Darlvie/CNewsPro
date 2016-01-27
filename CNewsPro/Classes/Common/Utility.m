//
//  Utility.m
//  CNewsPro
//
//  Created by zyq on 16/1/13.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "Utility.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "RequestMaker.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "MediaTypeXmlAnalytic.h"
#import "ManuscriptsDB.h"
#import "UploadManager.h"
#import "Manuscripts.h"
#import "AccessoriesDB.h"
#import "UploadMaker.h"
#import "ServerAddressDB.h"
#import "ServerAddress.h"
#import "ManuscriptTemplate.h"
#import "User.h"
#import "SendToAddress.h"
#import "SendToAddressDB.h"
#import "NSData+LTExtension.h"

#define FILE_PATH_INPHONE [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[USERDEFAULTS objectForKey:LOGIN_NAME]]

@implementation Utility

+ (instancetype)sharedSingleton {
    static dispatch_once_t onceToken;
    static Utility *sharedSingleton;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[Utility alloc] init];
    });
    return sharedSingleton; 
}

//检测网络是否畅通
+ (BOOL)testConnection {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags) {
        return NO;
    }
    
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    return (isReachable && !needsConnection) ? YES : NO;
}

//检测软件版本更新
+ (BOOL)checkNewVersion {
    NSURL *checkURL = [NSURL URLWithString:@"http://itunes.apple.com/lookup?id=767219089"];
    NSMutableURLRequest *checkRequest = [[NSMutableURLRequest alloc] initWithURL:checkURL
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:60.f];
    NSURLResponse *checkResponse = nil;
    NSError *checkError = nil;
    NSData *checkData = [NSURLConnection sendSynchronousRequest:checkRequest
                                              returningResponse:&checkResponse
                                                          error:&checkError];
    if (!checkError) {
        if (checkData) {
            NSMutableDictionary *loginAuthenticationResponse = [[NSMutableDictionary alloc] initWithDictionary:
                                                                [NSJSONSerialization JSONObjectWithData:checkData
                                                                                                options:NSJSONReadingMutableLeaves
                                                                                                  error:&checkError]];
            NSArray *configData = [loginAuthenticationResponse valueForKey:@"results"];
            NSString *version = @"";
            for (id config in configData) {
                version = [config valueForKey:@"version"];
            }
            if ([version floatValue] > [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]) {
                
                return FALSE;
            }
        }
    }
    return TRUE;
}

//校验当前程序版本是否符合发稿要求
+ (BOOL)checkVersion {
    NSString *versionXml = [RequestMaker getServerVersion];
    //自定义命名空间的xml文件无法解析，进行标准替换
    versionXml = [versionXml stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noxmlns"];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:versionXml options:0 error:nil];
    
    //解析
    NSArray *items = nil;
    items = [xmlDoc nodesForXPath:@"//iPhoneClient" error:nil];
    for (DDXMLElement *item in items) {
        float lowVersion = [[[item elementForName:@"VersionLowest"] stringValue] floatValue];
        [USERDEFAULTS setObject:[NSString stringWithFormat:@"%f",lowVersion] forKey:LOW_VERSION];
        float currentVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
        if (currentVersion < lowVersion) {
            return FALSE;
        }
    }
    return TRUE;
}

//同步获取用户信息
+ (void)initializeUserInfo {
    NSString *sessionId = [USERDEFAULTS objectForKey:SESSION_ID];
    NSString *loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    
    if ([sessionId isEqualToString:@""]) {
        return;
    } else {
        NSString *xmlStr = [RequestMaker syncGetUserInfo:sessionId loginName:loginName];
        if (!xmlStr) {
            return;
        } else {
            MediaTypeXmlAnalytic *mt = [[MediaTypeXmlAnalytic alloc] init];
            User *userInfo = [mt userInfoAnalytic:xmlStr];
            [Utility sharedSingleton].userInfo = userInfo;
            //userinfo持久化存储
            if (userInfo != nil) {
                [self saveUserInfo:userInfo];
            }
        }
    }
}

//将userinfo归档存储
+ (void)saveUserInfo:(User *)userInfo {
    NSString *saveFilePath = [FILE_PATH_INPHONE stringByAppendingPathComponent:@"userinfo"];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:userInfo forKey:DATA_KEY];
    [archiver finishEncoding];
    [data writeToFile:saveFilePath atomically:YES];
}

//将程序退出时没有执行的待发任务重新放入队列
+ (void)sendUnFinishedTaskToQueue {
    NSMutableArray *addArray = [[NSMutableArray alloc] init];
    ManuscriptsDB *mdb = [[ManuscriptsDB alloc] init];
    NSMutableArray *scriptItems = [mdb getManuscriptsByStatus:[USERDEFAULTS objectForKey:LOGIN_NAME]
                                                       status:MANUSCRIPT_STATUS_STAND_TO];
    
    if ([scriptItems count] > [[UploadManager sharedManager] uploadClientCount]) {
        if ([[UploadManager sharedManager] uploadClientCount] == 0) {
            for (int i = 0; i < scriptItems.count; i ++) {
                Manuscripts *manuscript = [scriptItems objectAtIndex:i];
                AccessoriesDB *adb = [[AccessoriesDB alloc] init];
                NSMutableArray *accessoriesList = [adb getAccessoriesListByMId:manuscript.m_id];
                if (accessoriesList.count > 0) {
                    [UploadMaker uploadWithFilePath:manuscript accessories:[accessoriesList objectAtIndex:0]];
                } else {
                    [UploadMaker uploadWithFilePath:manuscript accessories:nil];
                }
            }
        } else {
            for (int i = 0; i < scriptItems.count; i++) {
                Manuscripts *mscripts = [scriptItems objectAtIndex:i];
                for (int j = 0; j < [[UploadManager sharedManager] uploadClientCount]; j++) {
                    Manuscripts *upmascripts = [[UploadManager sharedManager] objectAtQueueIndex:j];
                    if ([upmascripts.m_id isEqualToString:mscripts.m_id]) {
                        break;
                    } else if (j == [[UploadManager sharedManager] uploadClientCount] - 1) {
                        [addArray addObject:mscripts];
                    }
                }
            }
            for (int k = 0; k < [addArray count]; k++) {
                AccessoriesDB *adb = [[AccessoriesDB alloc] init];
                Manuscripts *addscript = [addArray objectAtIndex:k];
                NSMutableArray *accessoriesList = [adb getAccessoriesListByMId:addscript.m_id];
                if (accessoriesList.count > 0) {
                    [UploadMaker uploadWithFilePath:addscript accessories:[accessoriesList objectAtIndex:0]];
                } else {
                    [UploadMaker uploadWithFilePath:addscript accessories:nil];
                }
            }
        }
    }
    
}

// 从文件中读取用户信息
+ (void)getUserInfoFromFile {
    NSString *saveFilePath = [FILE_PATH_INPHONE stringByAppendingPathComponent:@"userinfo"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:saveFilePath]) {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:saveFilePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        User *userInfo = [unarchiver decodeObjectForKey:DATA_KEY];
        [Utility sharedSingleton].userInfo = userInfo;
        [unarchiver finishDecoding];
    }
}

//生成log时间戳
+ (NSString *)getLogTimeStamp {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS ZZZ"];
    NSString *timeStamp = [formatter stringFromDate:date];
    return timeStamp;
}

//同步获取userInfo
+ (User *)getUserInfo {
    NSString *sessionId = [USERDEFAULTS objectForKey:SESSION_ID];
    NSString *loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    
    if ([sessionId isEqualToString:@""]) {
        return nil;
    } else {
        NSString *xmlStr = [RequestMaker syncGetUserInfo:sessionId loginName:loginName];
        if (!xmlStr) {
            return nil;
        } else {
            MediaTypeXmlAnalytic *mt = [[MediaTypeXmlAnalytic alloc] init];
            User *userInfo = [mt userInfoAnalytic:xmlStr];
            [Utility sharedSingleton].userInfo = userInfo;
            //userinfo持久化存储
            if (userInfo != nil) {
                [self saveUserInfo:userInfo];
            }
            [Utility sharedSingleton].userInfo = userInfo;
            return userInfo;
        }
    }
    return nil;
}

+ (void)getUrlArray {
    ServerAddressDB *sDB = [[ServerAddressDB alloc] init];
    ServerAddress *serverAddress = [sDB getDefaultServer];
    
    [RequestMaker getUrlArry:[serverAddress.code stringByAppendingString:@"client/wu"]];
}

//获取文件长度（字节数）
+ (NSUInteger)getFileLengthByPath:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        return [attributes fileSize];
    }
    return 0;
}

//根据范围获取部分文件数据
+ (NSData *)subDataWithRange:(NSRange)range filePath:(NSString *)filePath {
    NSData *subData = nil;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [fileHandle seekToFileOffset:range.location];
    subData = [fileHandle readDataOfLength:range.length];
    [fileHandle closeFile];
    
    return subData;
}

//校验稿件稿签中的发送地址与该用户被允许的发送地址是否匹配
+ (BOOL)checkSendToAddress:(User *)userInfo manuscriptTemplate:(ManuscriptTemplate *)manuTemplate {
    BOOL bRet = YES;
    NSArray *sendToListManu = [manuTemplate.address componentsSeparatedByString:@"，"];
    NSInteger checkCout = 0;
    
    //根据不同用户的角色，构造被允许的发送地址名称列表，用于校验
    NSMutableArray *sendToListPermitted = [[NSMutableArray alloc] init];
    
    NSArray *sendToListUser = userInfo.sendAdressList;
    for (int i = 0; i < sendToListUser.count; i++) {
        SendToAddress *sendToAddress1 = [sendToListUser objectAtIndex:i];
        [sendToListPermitted addObject:sendToAddress1.name];
    }
    
     //对于普通用户，追加基础数据库中的发送地址
    if ([userInfo.rightSendNews compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        SendToAddressDB *sendToAddressDB = [[SendToAddressDB alloc] init];
        NSArray *sendToListDB = [sendToAddressDB getSendToAddressList];
        for (int j = 0; j < sendToListDB.count; j++) {
            SendToAddress *sendToAddress2 = [sendToListDB objectAtIndex:j];
            [sendToListPermitted addObject:sendToAddress2.name];
        }
    }
    
    //校验
    for (int k = 0; k < sendToListManu.count; k++) {
        for (int p = 0; p < sendToListPermitted.count; p++) {
            if ([[sendToListManu objectAtIndex:k] isEqualToString:[sendToListPermitted objectAtIndex:p]]) {
                checkCout++;
                break;
            }
        }
    }
    
    if (checkCout < sendToListManu.count) {
        bRet = NO;
    }
    
    return bRet;
}

+ (void)getTemplate {
    [RequestMaker getTemplate:[USERDEFAULTS objectForKey:LOGIN_NAME]
                    sessionid:[USERDEFAULTS objectForKey:SESSION_ID]
                     delegate:self];
}

//生成随机UUID
+ (NSString *)stringWithUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidStr;
}


+ (NSString*)getFileMD5ByPath:(NSString*)filePath
{
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    return [fileData MD5];
}
















@end
