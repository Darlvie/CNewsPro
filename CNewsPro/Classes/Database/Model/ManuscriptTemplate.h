//
//  ManuscriptTemplate.h
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManuscriptTemplate : NSObject <NSCoding,NSCopying>

@property (nonatomic,copy) NSString *mt_id;//guid
@property (nonatomic,copy) NSString *name;//稿签名称
@property (nonatomic,copy) NSString *loginName;//创建者登陆名
@property (nonatomic,copy) NSString *comeFromDept;//支持多个，用“，”隔开
@property (nonatomic,copy) NSString *comeFromDeptID;//支持多个
@property (nonatomic,copy) NSString *region;//非洲－北非－埃及
@property (nonatomic,copy) NSString *regionID;//02001001
@property (nonatomic,copy) NSString *docType;//政治、法律－政治制度
@property (nonatomic,copy) NSString *docTypeID;//01002001
@property (nonatomic,copy) NSString *provType;//国内新闻/国际新闻
@property (nonatomic,copy) NSString *provTypeid;//01/02
@property (nonatomic,copy) NSString *keywords;//有默认列表选择，也可以自填
@property (nonatomic,copy) NSString *language;//中文／英文
@property (nonatomic,copy) NSString *languageID;//zh－cn
@property (nonatomic,copy) NSString *priority;//特急／普通
@property (nonatomic,copy) NSString *priorityID;//1.0／5.0
@property (nonatomic,copy) NSString *sendArea;//塔吉克斯坦  稿件从哪里过来，一般和下面两个地点重复
@property (nonatomic,copy) NSString *happenPlace;//
@property (nonatomic,copy) NSString *reportPlace;//
@property (nonatomic,copy) NSString *address;//发稿地址 支持多个，用“，”隔开
@property (nonatomic,copy) NSString *addressID;//发稿地址id，支持多个，用“，”隔开
@property (nonatomic,copy) NSString *is3Tnews;//0／1表示
@property (nonatomic,copy) NSString *isDefault;//0／1表示
@property (nonatomic,copy) NSString *createTime;//2012－5－8 21：40：30 最后一次编辑时间
@property (nonatomic,copy) NSString *reviewStatus;//送审时间
@property (nonatomic,copy) NSString *defaultTitle;//稿件默认标题
@property (nonatomic,copy) NSString *defaultContents;//稿件默认正文
@property (nonatomic,copy) NSString *isSystemOriginal;//
@property (nonatomic,copy) NSString *author;


@end
