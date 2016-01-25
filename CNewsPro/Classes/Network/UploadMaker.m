//
//  UploadMaker.m
//  CNewsPro
//
//  Created by hooper on 1/22/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "UploadMaker.h"
#import "Accessories.h"
#import "Manuscripts.h"
#import "UploadManager.h"

@implementation UploadMaker

+ (void)uploadWithFilePath:(Manuscripts *)manuscripts accessories:(Accessories *)accessories {
    NSMutableDictionary *uploadInfo = [[NSMutableDictionary alloc] init];
    if (accessories == nil) {
        [uploadInfo setObject:@"0" forKey:FILE_PATH];//附件路径
    }  else {
        [uploadInfo setObject:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:accessories.originName] forKey:FILE_PATH];
    }
    [uploadInfo setObject:[FILE_PATH_IN_PHONE stringByAppendingPathComponent:[manuscripts.m_id stringByAppendingString:@".xml"]] forKey:XML_PATH];
    [uploadInfo setObject:manuscripts forKey:MANUSCRIPT_INFO];//稿件信息
    [[UploadManager sharedManager] uploadWithInfo:uploadInfo];
}

@end
