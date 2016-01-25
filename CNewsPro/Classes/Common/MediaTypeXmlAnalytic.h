//
//  MediaTypeXmlAnalytic.h
//  CNewsPro
//
//  Created by zyq on 16/1/22.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface MediaTypeXmlAnalytic : NSObject

/**
 *  userinfo解析
 */
- (User *)userInfoAnalytic:(NSString *)xmlString;

/**
 *  发稿地址解析
 */
- (NSMutableArray *)sendAdressPathXmlAnalytic:(NSString *)fileName;

/**
 *  多语言解析
 */
- (NSMutableArray *)languageXmlAnalytic:(NSString *)FileName;

- (NSMutableArray *)xmlAnalysis:(NSString *)path;

@end
