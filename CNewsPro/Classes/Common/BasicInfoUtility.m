//
//  BasicInfoUtility.m
//  CNewsPro
//
//  Created by zyq on 16/1/22.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicInfoUtility.h"
#import "MediaTypeXmlAnalytic.h"
#import "SendToAddressDB.h"
#import "LanguageDB.h"
#import "NewTypeDB.h"
#import "RegionDB.h"
#import "PlaceDB.h"
#import "NewsCategoryDB.h"
#import "ComeFromAddressDB.h"
#import "ProvideTypeDB.h"
#import "NewsPriorityDB.h"
#import "ASIHTTPRequest.h"

@implementation BasicInfoUtility

//拷贝基础数据xml文件名的plist到document
- (BOOL)copyBasicInfoPlist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"BasicXmlList.plist"];
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    success = [fileManager fileExistsAtPath:filePath];
    if (success) {
        return TRUE;
    }
    //若document中基础数据文件不存在，则复制一份
    NSString *defaultXmlPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BasicXmlList.plist"];
    success = [fileManager copyItemAtPath:defaultXmlPath toPath:filePath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        return FALSE;
    }
    return TRUE;
}

////更新基础数据，如果存在可更新数据，则返回true,如果没有存在可更新数据，则返回false
- (BOOL)updateBasicInfo:(NSString *)result {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"BasicXmlList.plist"];
     //从plist中读取现有的xml基础数据w文件名称
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    //可更新的xmllist
    //如果有更新则更新相应的xml文件
    NSArray *updateXmlList = [result componentsSeparatedByString:@","];
    for (int i = 0; i < updateXmlList.count; i++) {
        if (![self getNewBasicInfo:[updateXmlList objectAtIndex:i]]) {
            //只要出现文件下载失败，就返回
            return FALSE;
        }
    }
    
    for (int j = 0; j < updateXmlList.count; j++) {
        NSString *newXml = [updateXmlList objectAtIndex:j];
        for (int k = 0; k < dic.count; k++) {
            NSString *dicStr = [dic objectForKey:[NSString stringWithFormat:@"%d",k]];
            //如果是同一文件的不同版本，则plist进行更新
            if ([self compareXmlFile:dicStr fileCompare:newXml]) {
                [dic setObject:newXml forKey:[NSString stringWithFormat:@"%d",k]];
                break;
            }
        }
    }
    //写入plist，更新xml版本
    [dic writeToFile:filePath atomically:YES];
    
    //更新基础数据库
    MediaTypeXmlAnalytic *xmlAnalytic = [[MediaTypeXmlAnalytic alloc] init];
    for (NSString *fileName in updateXmlList) {
        if ([self containSubString:fileName subString:@"SendAddress"]) {
            //对sendtoAddress 更新
            NSMutableArray *newData = [xmlAnalytic sendAdressPathXmlAnalytic:fileName];
            SendToAddressDB *sDB = [[SendToAddressDB alloc] init];
            if (newData.count != 0) {
                [sDB deleteAll];
                [sDB addSendAddressList:newData];
            }
        } else if ([self containSubString:fileName subString:@"Language"]) {
            // 对language更新,文种
            NSMutableArray *newData = [xmlAnalytic languageXmlAnalytic:fileName];
            if (newData.count != 0) {
                LanguageDB *lDB = [[LanguageDB alloc] init];
                [lDB deleteAll];
                [lDB addLanguageList:newData];
            }
        } else {
            // 对其他进行更新XmlAnalysis
            NSMutableArray *newData = [xmlAnalytic xmlAnalysis:fileName];
            if (newData.count != 0) {
                if ([self containSubString:fileName subString:@"MediaType"]) {
                    //稿件类型newstype
                    NewTypeDB *ntDB = [[NewTypeDB alloc] init];
                    [ntDB deleteAll];
                    [ntDB addNewsTypeList:newData];
                } else if ([self containSubString:fileName subString:@"GeographyCategory"]) {
                    //地区region
                    RegionDB *rDB = [[RegionDB alloc] init];
                    [rDB deleteAll];
                    [rDB addRegionList:newData];
                } else if ([self containSubString:fileName subString:@"WorldLocation"]) {
                    //单级地点 Place
                    PlaceDB *pDB = [[PlaceDB alloc] init];
                    [pDB deleteAll];
                    [pDB addPlaceList:newData];
                } else if ([self containSubString:fileName subString:@"Category"]) {
                    //稿件分类newscategory
                    NewsCategoryDB *nDB = [[NewsCategoryDB alloc] init];
                    [nDB deleteAll];
                    [nDB addNewsCategoryList:newData];
                } else if ([self containSubString:fileName subString:@"Department"]) {
                    //稿源comefromaddress
                    ComeFromAddressDB *cfaDB = [[ComeFromAddressDB alloc] init];
                    [cfaDB deleteAll];
                    [cfaDB addComeFromList:newData];
                } else if ([self containSubString:fileName subString:@"Internal"]) {
                    //供稿类别providetype
                    ProvideTypeDB *ptDB = [[ProvideTypeDB alloc] init];
                    [ptDB deleteAll];
                    [ptDB addProvideList:newData];
                } else if ([self compareXmlFile:fileName fileCompare:@"Importance"]) {
                    //优先级newspriority
                    NewsPriorityDB *npDB = [[NewsPriorityDB alloc] init];
                    [npDB deleteAll];
                    [npDB addPriorityList:newData];
                } else {
                    NSLog(@"无法识别是哪一个数据表需要更新");
                }
            }
        }
    }
    return TRUE;
}


//同步获得基础数据,根据文件名称，更新文件
- (BOOL)getNewBasicInfo:(NSString *)fileName {
    NSString *url = [NSString stringWithFormat:@"%@%@",GET_BASE_DATA_IP,fileName];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *responseString=[[NSString alloc] initWithData:[request responseData]
                                                       encoding:NSUTF8StringEncoding];
        NSData *contentData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        //生产新的文件//写入文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *newFileName = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm createFileAtPath:newFileName contents:nil attributes:nil]) {
            if ([contentData writeToFile:newFileName atomically:YES]) {
                return TRUE;
            } else {
                NSLog(@"写入文件失败");
                return FALSE;
            }
        } else {
            NSLog(@"创建文件失败");
            return FALSE;
        }
    } else {
        NSLog(@"获取基础数据失败");
        return FALSE;
    }
}

//检查xml文件是否是同一文件的不同版本:根据现有的xml文件名称特制比较方法
- (BOOL)compareXmlFile:(NSString *)fileName1 fileCompare:(NSString *)fileName2 {
    NSString *file1 = [[fileName1 componentsSeparatedByString:@"."] objectAtIndex:1];
    NSString *file2 = [[fileName2 componentsSeparatedByString:@"."] objectAtIndex:1];
    NSRange range1 = NSMakeRange(0, file1.length - 2);
    NSRange range2 = NSMakeRange(0, file2.length - 2);
    file1 = [file1 substringWithRange:range1];
    file2 = [file2 substringWithRange:range2];
    if ([file1 isEqualToString:file2]) {
        return TRUE;
    } else {
        return FALSE;
    }
}

//检测totalWorld中是否包含subworld,若存在返回true，否则返回false
- (BOOL)containSubString:(NSString *)totalWord subString:(NSString *)subWord {
    NSRange range = [totalWord rangeOfString:subWord options:NSCaseInsensitiveSearch];//不区分大小写
    if (range.location != NSNotFound) {
        return TRUE;
    } else {
        return FALSE;
    }
}

//从plist中读取现有的xml基础数据w文件名称,并串联成串
- (NSString *)getFileNameList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"BasicXmlList.plist"];
    //从plist中读取现有的xml基础数据w文件名称
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSString *xmlList = @"";
    for (int i = 0;i < dic.count ; i++) {
        xmlList = [xmlList stringByAppendingString:[dic objectForKey:[NSString stringWithFormat:@"%d",i]]];
        xmlList = [xmlList stringByAppendingString:@","];
    }
    //去掉最后一个“,”号
    xmlList = [xmlList substringToIndex:xmlList.length - 1];
    return xmlList;
}

//NSString判断基础数据是否有更新
- (NSString *)getFileNameWithNewBasicInfo:(NSString *)fileList {
    NSString *url =[NSString stringWithFormat:@"%@%@",MITI_IP,@"appServices!checkSystemConfig.action"];
    NSString *bodyStr = [NSString stringWithFormat:@"ua=%@&topiclist=%@",
                         @"gettopiclist",fileList];
    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld",[bodyData length]]];
    [request appendPostData:bodyData];
    [request setRequestMethod:POST];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        return [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"基础数据更新失败");
        return nil;
    }
}





























@end
