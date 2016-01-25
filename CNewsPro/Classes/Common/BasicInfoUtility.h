//
//  BasicInfoUtility.h
//  CNewsPro
//
//  Created by zyq on 16/1/22.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicInfoUtility : NSObject

/**
 *  拷贝基础数据xml文件名的plist到document
 */
- (BOOL)copyBasicInfoPlist;

- (BOOL)updateBasicInfo:(NSString*)result;

/**
 *  从plist中读取现有的xml基础数据w文件名称,并串联成串
 */
- (NSString *)getFileNameList;

/**
 *  NSString判断基础数据是否有更新
 *
 */
- (NSString*)getFileNameWithNewBasicInfo:(NSString *)fileList;

@end
