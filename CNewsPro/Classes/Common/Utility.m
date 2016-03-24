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
#import "AuditNewsItem.h"
#import "JSONKit.h"
#import "Accessories.h"
#import "ManuscriptsDB.h"
#import "UIDevice+IdentifierAddition.h"

//定义的归档的文件名与关键字
static NSString *kTemporaryTemplateFilename = @"temporaryTianJinTVArchive";
static NSString *kManuCountFile = @"manuCountDaily";
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

+ (NSString*)getNowDateTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
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

//校验稿件的稿签信息是否完整
+ (NSString *)checkInfoIsCompleted:(Manuscripts *)mcripts {
    if([[self trimBlankSpace:mcripts.mTemplate.address] isEqualToString:@""])
        return @"信息不全:(稿签)发稿通道";
    else
        return @"";
}

+ (NSString *)trimBlankSpace:(NSString *)inputStr
{
    return [inputStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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


+ (AuditNewsItem *)parseAuditNewsItemFromData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    
    AuditNewsItem *auditNewsItem = [[AuditNewsItem alloc]init];
    NSDictionary *auditDic = [[JSONDecoder decoder]objectWithData:data];
    auditNewsItem.anAbstract = [auditDic objectForKey:AN_ABSTRCT];
    auditNewsItem.auditNewsId = [[auditDic objectForKey:AUDIT_NEWS_ID]integerValue];
    auditNewsItem.author = [auditDic objectForKey:AUTHOR];
    auditNewsItem.channel = [auditDic objectForKey:CHANNEL];
    auditNewsItem.content = [auditDic objectForKey:CONTENT];
    auditNewsItem.createTime = [auditDic objectForKey:CREATE_TIME];
    auditNewsItem.status = [auditDic objectForKey:STATUS];
    auditNewsItem.title = [auditDic objectForKey:TITLE];
    auditNewsItem.videoSrc = [auditDic objectForKey:VIDEO_SRC];
    
    return auditNewsItem;

}

+ (NSMutableDictionary *)parseAuditNewsListFromData:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    //data是一个字典类型，包含items、currentPage、totalCount三个字段。
    NSDictionary *responseDic = [[JSONDecoder decoder] objectWithData:data];
    
    //返回这个解析之后的字典
    NSMutableDictionary *auditNewsDic = [[NSMutableDictionary alloc]init];
    NSMutableArray *auditNewsListArray = [[NSMutableArray alloc]init];
    
    NSMutableArray *tempArray = [responseDic objectForKey:@"items"];
    
    for (NSDictionary *tempDic in tempArray) {
        AuditNewsItem *newsItem = [self parseAuditNewsItemFromDic:tempDic];
        [auditNewsListArray addObject:newsItem];
    }
    [auditNewsDic setObject:auditNewsListArray forKey:@"items"];
    
    [auditNewsDic setObject:[responseDic objectForKey:@"currentPage"] forKey:@"currentPage"];
    [auditNewsDic setObject:[responseDic objectForKey:@"totalCount"] forKey:@"totalCount"];
    
    return auditNewsDic;
}

+ (AuditNewsItem *)parseAuditNewsItemFromDic:(NSDictionary *)auditDic
{
    AuditNewsItem *auditNewsItem = [[AuditNewsItem alloc]init];
    auditNewsItem.anAbstract = [auditDic objectForKey:AN_ABSTRCT];
    auditNewsItem.auditNewsId = [[auditDic objectForKey:AUDIT_NEWS_ID]integerValue];
    auditNewsItem.author = [auditDic objectForKey:AUTHOR];
    auditNewsItem.channel = [auditDic objectForKey:CHANNEL];
    auditNewsItem.content = [auditDic objectForKey:CONTENT];
    auditNewsItem.createTime = [auditDic objectForKey:CREATE_TIME];
    auditNewsItem.status = [auditDic objectForKey:STATUS];
    auditNewsItem.title = [auditDic objectForKey:TITLE];
    auditNewsItem.videoSrc = [auditDic objectForKey:VIDEO_SRC];
    
    return auditNewsItem;
}

+ (NSString *)temporaryTemplateFilePath {
    NSString *tempPath = NSTemporaryDirectory();
    return [tempPath stringByAppendingPathComponent:kTemporaryTemplateFilename];
}

//检测网络是否可用、服务器地址是否可用、版本是否符合发稿要求，以及稿件的稿签是否符合要求
+ (NSString *)serialCheckBeforeSendManu:(Manuscripts *)mcripts {
    //检测稿签信息是否完整，如果缺少必备信息，不发送
    NSString *checkInfo = [Utility checkInfoIsCompleted:mcripts];
    if( ![checkInfo isEqualToString:@""] ){
        return checkInfo;
    }else
    {
        if (![Utility testConnection] ) {
            //return @"当前网络不可用，请稍后再试";
            if ([USERDEFAULTS objectForKey:LOW_VERSION]) {
                float lowVersion = [[USERDEFAULTS objectForKey:LOW_VERSION] floatValue];
                float localVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
                if (localVersion < lowVersion) {
                    return @"当前版本过低，不能发稿";
                }
                else
                {
                    return @"";
                }
                
            }else
            {
                return @"";
            }
            
        }
        else
        {
            if (![Utility checkVersion]) {
                return @"当前版本过低，不能发稿";
            }else
            {
                return @"";
            }
        }
        
    }

}

//发送前的数据准备：属性赋值和拆条
+ (NSMutableArray *)prepareToSendManuscript:(Manuscripts *)manuscript accessories:(NSMutableArray *)accessoriesArry userInfoFromServer:(User *)userInfo {
    NSMutableArray *mscriptArray = [[NSMutableArray alloc] initWithCapacity:0];

    //从UserInfo中获取相关信息
    if(!userInfo)
        userInfo = [Utility getUserInfo];
    if(userInfo)
    {
        if( userInfo.userNameC )
            manuscript.userNameC = userInfo.userNameC;
        if( userInfo.userNameE )
            manuscript.userNameE = userInfo.userNameE;
        if( userInfo.groupNameC )
            manuscript.groupNameC = userInfo.groupNameC;
        if( userInfo.groupNameE )
            manuscript.groupNameE = userInfo.groupNameE;
        if( userInfo.groupCode )
            manuscript.groupCode = userInfo.groupCode;
        
        //3、稿件状态
        manuscript.manuscriptsStatus = MANUSCRIPT_STATUS_EDITING;   //稿件状态。必填。
        
        //4、定位信息 // to be modified
        
        //5、发送时间
        manuscript.sentTime = [Utility getLogTimeStamp];//发送前写入
        manuscript.releTime = [Utility getLogTimeStamp];
        
        //6、根据附件的内容进行稿件的拆条(目前文字快讯不需要，日后修改)
        if( [accessoriesArry count] > 0 )
        {
            for (int i=0; i<[accessoriesArry count]; i++)
            {
                Accessories *accessorytemp = [accessoriesArry objectAtIndex:i];
                
                //根据附件类型对稿件的newstype和newstypeid字段赋值
                if( [accessorytemp.type isEqualToString:@"PHOTO"] )
                {
                    manuscript.newsType = PICTURE_MANU_C;
                    manuscript.newsTypeID = PICTURE_MANU_E;
                }
                else if ([accessorytemp.type isEqualToString:@"AUDIO"]) {
                    manuscript.newsType = AUDIO_MANU_C;
                    manuscript.newsTypeID = AUDIO_MANU_E;
                }
                else if ([accessorytemp.type isEqualToString:@"VIDEO"]) {
                    manuscript.newsType = VIDEO_MANU_C;
                    manuscript.newsTypeID = VIDEO_MANU_E;
                }
                
                //生成CreateId并赋值
                manuscript.createId = [self generateCreateId:manuscript];
                
                ManuscriptsDB *manuscriptsdb = [[ManuscriptsDB alloc] init];
                if(i == 0)
                {
                    //第一条附件只需更新对应的稿件类别和尚未赋值的CreateId
                    [manuscriptsdb updateManuscript:manuscript];
                }
                else
                {
                    //从第二条开始，新插入稿件并且更新对应的附件m_id
                    manuscript.m_id = [self stringWithUUID];
                    [manuscriptsdb addManuScript:manuscript];
                    
                    AccessoriesDB *accessoriesdb = [[AccessoriesDB alloc] init];
                    accessorytemp.m_id = manuscript.m_id;
                    [accessoriesdb updateAccessories:accessorytemp];
                }
                
                //将拆分后的稿件加入需要返回的数组
                Manuscripts *manuTemp = [manuscriptsdb getManuscriptById:manuscript.m_id];
                
                [mscriptArray insertObject:manuTemp atIndex:[mscriptArray count]];
                
            }
        }
        else //说明没有附件，属于“文字稿”，则不需拆条
        {
            manuscript.newsType = TEXT_MANU_C;
            manuscript.newsTypeID = TEXT_MANU_E;
            manuscript.createId = [self generateCreateId:manuscript];
            
            //对数据库信息进行更新
            ManuscriptsDB *manuscriptsdb = [[ManuscriptsDB alloc] init];
            [manuscriptsdb updateManuscript:manuscript];

            [mscriptArray addObject:manuscript];
        }
    }
    
    return mscriptArray;

}

+ (NSString *)generateCreateId:(Manuscripts *)manuTemp
{
    NSString *systemID = @"Mnews";
    NSString *serverNum = @"2";
    NSString *language = [self getLanguage:manuTemp.mTemplate.languageID];
    
    //序列号
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString *today = [formatter stringFromDate:[NSDate date]];
    NSString *serialNum = [self getAndSetSerialNumInFile:today];
    NSString *systemToken = @"EN";
    NSString *manuType = manuTemp.newsTypeID;
    NSString *manuLevel = @"S";//未定稿 S；成品稿 F
    NSString *manuFlow = @"N";//正常稿件 N
    NSString *version = @"0";//成品稿版本 0 原始版本
    
    NSString *createId = [NSString stringWithFormat:@"%@%@%@%@_%@_%@%@%@%@%@",
                          systemID,serverNum,language,serialNum,
                          today,
                          systemToken,
                          manuType,
                          manuLevel,
                          manuFlow,
                          version];
    return createId;
}

// 根据稿签中的语种，得到对应的文种标识
+ (NSString *)getLanguage:(NSString *)languageID
{
  if( [languageID isEqualToString:@"zh-CN"] )
      return @"C";
  if( [languageID isEqualToString:@"en"] )
      return @"E";
  if( [languageID isEqualToString:@"fr"] )
      return @"F";
  if( [languageID isEqualToString:@"es"] )
      return @"S";
  if( [languageID isEqualToString:@"ru"] )
      return @"R";
  if( [languageID isEqualToString:@"ar"] )
      return @"A";
  if( [languageID isEqualToString:@"pt"] )
      return @"P";
  if( [languageID isEqualToString:@"ja"] )
      return @"J";
  if( [languageID isEqualToString:@"ko"] )
      return @"K";
  if( [languageID isEqualToString:@"zh-TW"] )
      return @"T";
  
  return @"B";    //其它认为是双语
}

//根据当天日期获取对应的序列号（从document下的当前用户目录下的文件中读取）
+ (NSString *)getAndSetSerialNumInFile:(NSString *)today
{
    NSString *serialNum = @"009000";
    int count = 0;
    
    NSString *fileName = [FILE_PATH_IN_PHONE stringByAppendingPathComponent:kManuCountFile];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:fileName] )
    {
        //read
        NSString *manuCount = [NSString stringWithContentsOfFile:fileName encoding:NSASCIIStringEncoding error:nil];
        
        //spell serialNum
        if( ![manuCount isEqualToString:@""] )
        {
            if( [today isEqualToString:[manuCount substringToIndex:8]] )
            {
                count = [[manuCount substringFromIndex:9] intValue];
            }
        }
        
        count += 1;
        if( count < 1000 )
        {
            serialNum = [NSString stringWithFormat:@"00%@",[NSString stringWithFormat: @"%d", 9000 + count]];
        }
        else {
            serialNum = [NSString stringWithFormat:@"0%@",[NSString stringWithFormat: @"%d", 9000 + count]];
        }
    }
    //write serialNum to file
    NSString *content = [NSString stringWithFormat:@"%@-%@",today,[NSString stringWithFormat:@"%d",count]];
    NSData *contentData = [content dataUsingEncoding:NSASCIIStringEncoding];
    if ([contentData writeToFile:fileName atomically:YES]) {
        
    }
    
    return serialNum;
}

//拼接xml
+ (void)xmlPackage:(Manuscripts *)mscripts accessories:(Accessories *)accessories {
    
    ManuscriptsDB *mdb = [[ManuscriptsDB alloc] init];
    [mdb setManuscriptStatus:MANUSCRIPT_STATUS_STAND_TO mId:mscripts.m_id];
    
    //标题进行拆分更新
    if (![accessories.title isEqualToString:@""] && accessories.title != NULL) {
        mscripts.title=[NSString stringWithFormat:@"%@%@%@",mscripts.title,@" ",accessories.title];
        if (![accessories.desc isEqualToString:@""]&&accessories.desc!=NULL)
        {
            mscripts.contents=[NSString stringWithFormat:@"%@\n%@",mscripts.contents,accessories.desc];
        }
        [mdb updateManuscriptTitle:mscripts.title content:mscripts.contents m_id:mscripts.m_id];
    }

    DDXMLElement *rootelement=[[DDXMLElement alloc] initWithName:@"eNews"];
    [rootelement addAttributeWithName:@"version" stringValue:@"v001"];
    
    NSMutableDictionary *localinfo = [NSMutableDictionary dictionaryWithCapacity:5];
    [localinfo setObject:@"eNews.MobileClient.iPhone" forKey:@"SystemId"];//来稿方式，系统标识
    [localinfo setObject:mscripts.createId forKey:@"NewsId"];//稿号!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //正文标题拼上附件的标题
    [localinfo setObject:mscripts.title forKey:@"Title"];//标题
    
    [localinfo setObject:mscripts.mTemplate.author forKey:@"Author"];//作者
    [localinfo setObject:mscripts.mTemplate.keywords forKey:@"Keywords"];//关键字
    
    NSMutableArray *localinfoarry = [self getElement:localinfo];
    for (int i=0; i<[localinfoarry count]; i++) {
        DDXMLElement *element=(DDXMLElement *)[localinfoarry objectAtIndex:i];
        [rootelement addChild:element];
    }
    
    //uploader  由接收方填写
    NSMutableDictionary *info=[NSMutableDictionary dictionaryWithCapacity:7];
    [info setObject:[USERDEFAULTS objectForKey:LOGIN_NAME] forKey:@"login"];
    [info setObject:mscripts.userNameC forKey:@"cname"];
    [info setObject:mscripts.userNameE forKey:@"ename"];
    [info setObject:mscripts.groupCode forKey:@"groupid"];
    [info setObject:mscripts.groupNameC forKey:@"cgroup"];
    [info setObject:mscripts.groupNameE forKey:@"egroup"];
    [info setObject:@"" forKey:@"id"];
    
    NSMutableArray *infoarry=[self getElement:info];
    DDXMLElement *UploadInfo=[[DDXMLElement alloc] initWithName:@"Uploader"];
    for (int i=0; i<[infoarry count]; i++) {
        DDXMLElement *element=[infoarry objectAtIndex:i];
        [UploadInfo addChild:element];
    }
    [rootelement addChild:UploadInfo];
    
    //Time
    NSMutableDictionary *time=[NSMutableDictionary dictionaryWithCapacity:3];
    [time setObject:[Utility getLogTimeStamp] forKey:@"ReleTime"];//签发时间（需要加上时区）
    [time setObject:mscripts.createTime forKey:@"CreateTime"];//创建时间
    [time setObject:mscripts.receiveTime forKey:@"ReceiveTime"];
    
    NSMutableArray *timeArray = [self getElement:time];
    DDXMLElement *timeelement=[[DDXMLElement alloc] initWithName:@"Time"];
    for (int i=0; i<[timeArray count]; i++) {
        DDXMLElement *element=[timeArray objectAtIndex:i];
        [timeelement addChild:element];
    }
    [rootelement addChild:timeelement];
   
    //Language
    DDXMLElement *LanguageElement=[[DDXMLElement alloc] initWithName:@"Language"];
    [LanguageElement setStringValue:mscripts.mTemplate.language];
    [LanguageElement addAttributeWithName:@"id" stringValue:mscripts.mTemplate.languageID];
    [rootelement addChild:LanguageElement];
    
    //Priority 优先级
    DDXMLElement *PriorityElement=[[DDXMLElement alloc] initWithName:@"Priority"];
    [PriorityElement setStringValue:mscripts.mTemplate.priority];
    [PriorityElement addAttributeWithName:@"id" stringValue:mscripts.mTemplate.priorityID];
    [rootelement addChild:PriorityElement];
    
    //ProvType 供稿类别
    DDXMLElement *ProvTypeElement=[[DDXMLElement alloc] initWithName:@"ProvType"];
    [ProvTypeElement setStringValue:mscripts.mTemplate.provType];
    [ProvTypeElement addAttributeWithName:@"id" stringValue:mscripts.mTemplate.provTypeid];
    [rootelement addChild:ProvTypeElement];
   
    //DocType 分类
    DDXMLElement *DocTypeElement=[[DDXMLElement alloc] initWithName:@"DocType"];
    [DocTypeElement setStringValue:mscripts.mTemplate.docType];
    [DocTypeElement addAttributeWithName:@"id" stringValue:mscripts.mTemplate.docTypeID];
    [rootelement addChild:DocTypeElement];
    
    //SourceInfo  稿源
    DDXMLElement *SourceInfoElement = [[DDXMLElement alloc] initWithName:@"SourceInfo"];
    NSArray *AddressArry = [mscripts.mTemplate.comeFromDept componentsSeparatedByString:@"，"];
    NSArray *AddressIdArry = [mscripts.mTemplate.comeFromDeptID componentsSeparatedByString:@"，"];
    [SourceInfoElement addAttributeWithName:@"count" stringValue: [NSString stringWithFormat: @"%ld", [AddressArry count]]];
    for (int i=0; i<[AddressArry count]; i++) {
        DDXMLElement *SourceInfoItemElement=[[DDXMLElement alloc] initWithName:@"item"];
        [SourceInfoItemElement setStringValue:[AddressArry objectAtIndex:i]];
        [SourceInfoItemElement addAttributeWithName:@"id" stringValue:[AddressIdArry objectAtIndex:i]];
        [SourceInfoItemElement addAttributeWithName:@"sn" stringValue:[NSString stringWithFormat:@"%d",i+1]];
        [SourceInfoElement addChild:SourceInfoItemElement];
    }
    [rootelement addChild:SourceInfoElement];
    
    //Locations 各种地点
    DDXMLElement *LocationsElement=[[DDXMLElement alloc] initWithName:@"Locations"];
    DDXMLElement *HappenPlaceElement=[[DDXMLElement alloc] initWithName:@"HappenPlace"];
    [HappenPlaceElement setStringValue:mscripts.mTemplate.happenPlace];
    [LocationsElement addChild:HappenPlaceElement];
    
    DDXMLElement *ReportPlaceElement=[[DDXMLElement alloc] initWithName:@"ReportPlace"];
    [ReportPlaceElement setStringValue:mscripts.mTemplate.reportPlace];
    [LocationsElement addChild:ReportPlaceElement];
    
    DDXMLElement *SendAreaElement=[[DDXMLElement alloc] initWithName:@"SendArea"];
    [SendAreaElement setStringValue:mscripts.mTemplate.sendArea];
    [LocationsElement addChild:SendAreaElement];
    
    DDXMLElement *RegionElement=[[DDXMLElement alloc] initWithName:@"Region"];
    [RegionElement setStringValue:mscripts.mTemplate.region];
    [RegionElement addAttributeWithName:@"id" stringValue:mscripts.mTemplate.regionID];
    [LocationsElement addChild:RegionElement];
    [rootelement addChild:LocationsElement];
    
    //SendTo  发稿地址
    DDXMLElement *SendToElement=[[DDXMLElement alloc] initWithName:@"SendTo"];
    NSArray *SendToArry=[mscripts.mTemplate.address componentsSeparatedByString:@"，"];
    NSArray *SendToIdArry=[mscripts.mTemplate.addressID componentsSeparatedByString:@"，"];
    //zyq,2013/9/3,添加属性manuscriptType
    [SendToElement addAttributeWithName:@"manuscriptType" stringValue:@"MANUSCRIPT"];
    [SendToElement addAttributeWithName:@"be3t" stringValue: @"false"];//！！！！！！！！暂时不3t稿
    [SendToElement addAttributeWithName:@"count" stringValue: [NSString stringWithFormat: @"%ld", [SendToArry count]]];
    
    //！！！！！！！！暂时不支持
    for (int i=0; i<[SendToArry count]; i++) {
        DDXMLElement *SourceInfoItemElement=[[DDXMLElement alloc] initWithName:@"item"];
        [SourceInfoItemElement setStringValue:[SendToArry objectAtIndex:i]];
        [SourceInfoItemElement addAttributeWithName:@"id" stringValue:[SendToIdArry objectAtIndex:i]];
        [SourceInfoItemElement addAttributeWithName:@"sn" stringValue:[NSString stringWithFormat:@"%d",i+1]];
        [SendToElement addChild:SourceInfoItemElement];
    }
    [rootelement addChild:SendToElement];
    
    NSString *deviceCode=[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    //zyq,2013/8/28,添加DeviceId的字段
    DDXMLElement *DeviceIdElement = [[DDXMLElement alloc]initWithName:@"DeviceId"];
    [DeviceIdElement setStringValue:deviceCode];
    [rootelement addChild:DeviceIdElement];
    
    //Attach 附件
    if (accessories==nil) {
        DDXMLElement *AttachElement=[[DDXMLElement alloc] initWithName:@"Attach"];
        [AttachElement addAttributeWithName:@"count" stringValue:@"0"];
        [rootelement addChild:AttachElement];
    }
    else {
        DDXMLElement *AttachElement=[[DDXMLElement alloc] initWithName:@"Attach"];
        [AttachElement addAttributeWithName:@"count" stringValue:@"1"];
        
        DDXMLElement *ItemElement=[[DDXMLElement alloc] initWithName:@"item"];
        [ItemElement addAttributeWithName:@"sn" stringValue:@"1"];//!!!!!!!!!!!!!默认只有一个附件！！！！！！！！！
        [ItemElement addAttributeWithName:@"size" stringValue:accessories.size];
        [ItemElement addAttributeWithName:@"origin" stringValue:accessories.originName];
        [ItemElement addAttributeWithName:@"info" stringValue:accessories.info];
        NSString *type = [[accessories.originName componentsSeparatedByString:@"."] objectAtIndex:1];
        [ItemElement setStringValue:[NSString stringWithFormat:@"%@%@",@"1.",type]];//
        [AttachElement addChild:ItemElement];
        [rootelement addChild:AttachElement];
    }
    
    //Contents 正文
    DDXMLElement *ContentsElement=[[DDXMLElement alloc] initWithName:@"Contents"];
    DDXMLElement *TextElement=[[DDXMLElement alloc] initWithName:@"Text"];
    [TextElement addAttributeWithName:@"wordcount" stringValue: [NSString stringWithFormat:@"%ld",[mscripts.contents length]]];
    [TextElement setStringValue:mscripts.contents];
    
    [ContentsElement addChild:TextElement];
    [rootelement addChild:ContentsElement];
    
    //送审状态
    DDXMLElement *ReviewStatusElement=[[DDXMLElement alloc] initWithName:@"ReviewStatus"];
    [ReviewStatusElement setStringValue:mscripts.mTemplate.reviewStatus];
    [rootelement addChild:ReviewStatusElement];
   
    //定位信息
    DDXMLElement *GeographyPositionElement=[[DDXMLElement alloc] initWithName:@"GeographyPosition"];
    [GeographyPositionElement setStringValue:mscripts.location];
    [rootelement addChild:GeographyPositionElement];
 
    
    NSString *xmlstring=[NSString stringWithFormat:@"%@%@",@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>",[rootelement  XMLString]];
    xmlstring=[xmlstring stringByReplacingOccurrencesOfString:@"><" withString:@">\n<"];
    //mscripts.m_id=[self stringWithUUID];//guid应该由新建页生成的
    NSData *xmldata=[xmlstring dataUsingEncoding:NSUTF8StringEncoding];
    NSString *xmlname=[mscripts.m_id stringByAppendingString:@".xml"];
    
    if([xmldata writeToFile:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:xmlname] atomically:YES])
    {
        
        [UploadMaker uploadWithFilePath:mscripts accessories:accessories];
    }
    else {
        NSLog(@"失败");
    }
}

+ (NSMutableArray*)getElement:(NSMutableDictionary *)mdic
{
    NSMutableArray *na = [[NSMutableArray alloc] init];
    NSEnumerator *keys = [mdic keyEnumerator];
    id key;
    while (key = [keys nextObject]) {
        
        DDXMLElement *element=[[DDXMLElement alloc] initWithName:key];
        [element setStringValue:[mdic objectForKey:key]];
        [na addObject:element];
    }
    return na;
    
}

//批量发送多个稿件，用于在编稿件列表多选稿件后点击发送
+ (NSString *)sendManuscriptList:(NSMutableArray *)manuIdList
{
    //循环检测稿件和稿签信息是否完整、发送地址是否匹配。发现某个稿件不符合要求，则提示用户；循环结束后，将符合要求的稿件列表统一发送。
    NSMutableArray *manuListToSend = [[NSMutableArray alloc] initWithCapacity:0];
    ManuscriptsDB *manuscriptsdb = [[ManuscriptsDB alloc] init];
    for (int i= 0; i < manuIdList.count; i++) {
        NSString *mid = [manuIdList objectAtIndex:i];
        
        Manuscripts *manuTemp = [manuscriptsdb getManuscriptById:mid];
        if([manuTemp.title isEqualToString:@""])//标题不能为空
        {
            NSString *msg = [NSString stringWithFormat:@"第%d条：%@\n%@",i+1,@"",@"标题为空"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"校验信息" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
        else {
            NSString *checkInfo = [Utility checkInfoIsCompleted:manuTemp];
            if(![checkInfo isEqualToString:@""])
            {
                NSString *msg = [NSString stringWithFormat:@"第%d条：%@\n%@",i+1,manuTemp.title,checkInfo];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"校验信息" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            }
            else {
                if(![Utility checkSendToAddress:[Utility sharedSingleton].userInfo manuscriptTemplate:manuTemp.mTemplate])
                {
                    NSString *msg = [NSString stringWithFormat:@"第%d条：%@\n%@",i+1,manuTemp.title,@"发稿通道校验失败"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"校验信息" message:msg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                    [alert show];
                }
                else {
                    [manuListToSend addObject:manuTemp];
                }
            }
        }
    }
    
    //有稿件符合要求，才读取网络上的UserInfo，因为UserInfo获取较慢
    if( [manuListToSend count] > 0 )
    {
        NSString *ret = @"全部校验通过，请到待发稿件中查看发送进程";
        if ([manuListToSend count] < [manuIdList count]) {
            ret = @"部分稿件校验通过，请到待发稿件中查看发送进程";
        }
        
        //send
        [Utility sendManuThread:manuListToSend userInfoPara:[Utility sharedSingleton].userInfo];
        
        return ret;
    }
    else {
        return @"校验不通过，未发送";
    }
    
    return @"";
}


//在新建的线程中进行稿件拆分，然后给发送模块。
+ (void)sendManuThread:(NSMutableArray *)manuToSendList userInfoPara:(User *)userInfo
{
    //声明提交给发送模块的稿件列表和对应的相同数量的附件列表
    NSMutableArray *manuSendList = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *accessorySendList = [[NSMutableArray alloc] initWithCapacity:0];
    
    //保存传入参数
    NSMutableArray *manuList = manuToSendList;//manuList retain count = 1
    
    //循环拆分稿件，将拆分的稿件列表和附件列表保存在manuSendList和accessorySendList中
    AccessoriesDB *accDB = [[AccessoriesDB alloc] init];
    for (int i=0; i<manuList.count; i++) {
        Manuscripts *mscriptTemp = [manuList objectAtIndex:i];
        NSMutableArray *accessoryList = [accDB getAccessoriesListByMId:mscriptTemp.m_id];//accessoryList RC=1
        
        //根据附件拆分稿件，每个附件对应一个新的稿件
        NSMutableArray *manuSplitedArray = [Utility prepareToSendManuscript:mscriptTemp
                                                                accessories:accessoryList
                                                         userInfoFromServer:userInfo];
        for (int j=0; j<manuSplitedArray.count; j++) {
            [manuSendList insertObject:[manuSplitedArray objectAtIndex:j] atIndex:manuSendList.count];
            if([accessoryList count] > 0)
                [accessorySendList insertObject:[accessoryList objectAtIndex:j] atIndex:accessorySendList.count];
            else {
                [accessorySendList insertObject:@"" atIndex:accessorySendList.count];
            }
        }
    }
    
    //将准备好的稿件列表和附件列表循环传给发送模块
    for (int m=0; m<[manuSendList count]; m++) {
        
        if( [[accessorySendList objectAtIndex:m] isEqual:@""] )
            [Utility xmlPackage:[manuSendList objectAtIndex:m] accessories:nil];
        else
            [Utility xmlPackage:[manuSendList objectAtIndex:m] accessories:[accessorySendList objectAtIndex:m]];
    }

}

+ (NSString*)getLocalTimeStamp:(NSString*)utcTimeStamp {
    
    NSDateFormatter* utcFmt = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    
    [utcFmt  setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS ZZZ"];
    NSDate *date =[utcFmt dateFromString:utcTimeStamp];
    
    NSDateFormatter *localFmt = [[NSDateFormatter alloc] init];
    [localFmt setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    return [localFmt stringFromDate:date];
}

//图片压缩
+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)scale:(UIImage *)image toHeight:(float)height
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * height/image.size.height, height));
    [image drawInRect:CGRectMake(0, 0, image.size.width * height/image.size.height, height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
