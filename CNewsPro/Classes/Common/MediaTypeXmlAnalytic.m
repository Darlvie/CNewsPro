//
//  MediaTypeXmlAnalytic.m
//  CNewsPro
//
//  Created by zyq on 16/1/22.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "MediaTypeXmlAnalytic.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "User.h"
#import "SendToAddress.h"
#import "Language.h"
#import "CommonModel.h"

@implementation MediaTypeXmlAnalytic

//userinfo解析
- (User *)userInfoAnalytic:(NSString *)xmlString {
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:xmlString
                                                             options:0
                                                               error:nil];
    User *user = [[User alloc] init];
    DDXMLElement *infoUserName = [[xmlDoc nodesForXPath:@"//ChnFullName" error:nil] objectAtIndex:0];
    if ([infoUserName stringValue] != nil) {
        user.userNameC = [infoUserName stringValue];
    } else {
        return nil;
    }
    
    user.userNameE = [[[xmlDoc nodesForXPath:@"//EngFullName" error:nil] objectAtIndex:0] stringValue];
    user.groupCode = [[[xmlDoc nodesForXPath:@"//GroupId" error:nil] objectAtIndex:0] stringValue];
    user.groupNameC = [[[xmlDoc nodesForXPath:@"//ChnGroupName" error:nil] objectAtIndex:0] stringValue];
    user.groupNameE = [[[xmlDoc nodesForXPath:@"//EngGroupName" error:nil] objectAtIndex:0] stringValue];
    user.rightDisabled = [[[xmlDoc nodesForXPath:@"//Disabled" error:nil] objectAtIndex:0] stringValue];
    DDXMLElement *sendNews = [[xmlDoc nodesForXPath:@"//SendNews" error:nil] objectAtIndex:0];
    user.rightSendNews = [sendNews stringValue];
    DDXMLElement *transferNews = [[xmlDoc nodesForXPath:@"//TransferNews" error:nil] objectAtIndex:0];
    user.rightTransferNews = [transferNews stringValue];
    user.rightReleNews = [[[xmlDoc nodesForXPath:@"//ReleNews" error:nil] objectAtIndex:0] stringValue];
    user.rightAuditNews = [[[xmlDoc nodesForXPath:@"//AuditNews" error:nil] objectAtIndex:0] stringValue];
    
    NSArray *items = [[NSArray alloc] init];
    if ([[sendNews stringValue] isEqualToString:@"true"]) {
        if ([[xmlDoc nodesForXPath:@"//AddressList" error:nil] count]) {
            DDXMLElement *addressList = [[xmlDoc nodesForXPath:@"//AddressList " error:nil] objectAtIndex:0];
            items = [addressList nodesForXPath:@"//item " error:nil];
        } else {
            user.sendAdressList = nil;
            return user;
        }
    } else if ([[transferNews stringValue] isEqualToString:@"true"]) {
        if ([[xmlDoc nodesForXPath:@"//TransferAddressList " error:nil] count]) {
            DDXMLElement *transferAddressList = [[xmlDoc nodesForXPath:@"//TransferAddressList " error:nil] objectAtIndex:0];
            items = [transferAddressList nodesForXPath:@"//item " error:nil];
        } else {
            user.sendAdressList = nil;
            return user;
        }
    }
    
    NSMutableArray *sendArray = [[NSMutableArray alloc] init];
    for (DDXMLElement *item in items) {
        SendToAddress *sendToAddress = [[SendToAddress alloc] init];
        sendToAddress.name = [item stringValue];
        sendToAddress.code = [item stringValue];
        [sendArray addObject:sendToAddress];
    }
    user.sendAdressList = sendArray;
    return user;
}

//发稿地址解析
- (NSMutableArray *)sendAdressPathXmlAnalytic:(NSString *)fileName {
    NSMutableArray *sendAddressList = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:filePath]) {
        NSLog(@"%@",@"不存在");
        return sendAddressList;
    }
    
    NSString *xmlStr = [[NSString alloc] initWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    //自定义命名空间的xml文件无法解析，进行标准替换
    xmlStr = [xmlStr stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noxmlns"];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:xmlStr options:0 error:nil];
    
    NSArray *items = nil;
    items = [xmlDoc nodesForXPath:@"//Topic" error:nil];
    for (DDXMLElement *item in items) {
        NSString *code = [[item attributesAsDictionary] objectForKey:@"topicId"];
        NSString *name = [[item elementForName:@"Name"] stringValue];
        NSArray *descriptionList = [item nodesForXPath:@"Description" error:nil];
        SendToAddress *sendAddress = [[SendToAddress alloc] init];
        sendAddress.code = code;
        sendAddress.name = name;
        for (DDXMLElement *element in descriptionList) {
            NSString *kind = [[element attributesAsDictionary] objectForKey:@"kind"];
            if ([kind isEqualToString:@"Order"]) {
                sendAddress.order = [element stringValue];
            }
            if ([kind isEqualToString:@"Language"]) {
                sendAddress.language = [element stringValue];
            }
        }
        [sendAddressList addObject:sendAddress];
    }
    return sendAddressList;
}

//LanguageXml 解析
- (NSMutableArray *)languageXmlAnalytic:(NSString *)FileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:FileName];
    NSString *xmlStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    //自定义命名空间的xml文件无法解析，进行标准替换
    xmlStr = [xmlStr stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noxmlns"];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:xmlStr options:0 error:nil];
    
    NSMutableArray *languageList = [[NSMutableArray alloc] init];
    NSArray *items = nil;
    items = [xmlDoc nodesForXPath:@"//Topic" error:nil];
    for (DDXMLElement *item in items) {
        NSString *code = [[item attributesAsDictionary] objectForKey:@"topicId"];
        NSString *l_id = [[item attributesAsDictionary] objectForKey:@"id"];
        NSArray *nameArray = [item nodesForXPath:@"Name" error:nil];
        for (DDXMLElement *element in nameArray) {
            Language *language = [[Language alloc] init];
            language.l_id = l_id;
            language.code = code;
            language.language = [[element attributesAsDictionary] objectForKey:@"lang"];
            language.name = [element stringValue];
            language.code = @"";
            [languageList addObject:language];
        }
    }
    return languageList;
}

- (NSMutableArray *)xmlAnalysis:(NSString *)path {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    NSString *xmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    xmlStr = [xmlStr stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noxmlns"];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:xmlStr options:0 error:nil];
    
    NSMutableArray *objectList = [[NSMutableArray alloc] init];
    NSArray *items = nil;
    items = [xmlDoc nodesForXPath:@"//Topic" error:nil];
    for (DDXMLElement *item in items) {
        NSString *code = [[item attributesAsDictionary] objectForKey:@"topicId"];
        NSArray *nameArray = [item nodesForXPath:@"Name" error:nil];
        for (DDXMLElement *element in nameArray) {
            CommonModel *cObject = [[CommonModel alloc] init];
            cObject.code = code;
            cObject.language = [[element attributesAsDictionary] objectForKey:@"lang"];
            cObject.name = [element stringValue];
            [objectList addObject:cObject];
        }
    }
    return objectList;
}


















@end
