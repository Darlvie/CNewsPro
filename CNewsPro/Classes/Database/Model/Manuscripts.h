//
//  Manuscripts.h
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ManuscriptTemplate;
@interface Manuscripts : NSObject

                                                          //含义            //何处负责写入       //备注
@property (nonatomic,copy) NSString *m_id;                //稿件id           z“新建稿件”         客户端自动生成的GUID
@property (nonatomic,copy) NSString *createId;            //处理稿号          z“新建稿件”         根据规则客户端生成
@property (nonatomic,copy) NSString *releId;              //签发稿号            ？？
@property (nonatomic,copy) NSString *newsId;              //回传稿号          lw“发送”成功后更新
@property (nonatomic,copy) NSString *title;               //稿件标题          z“新建稿件”
@property (nonatomic,copy) NSString *title3T;             //3T稿件标题        ----
@property (nonatomic,copy) NSString *userNameC;           //中文名            z“新建稿件”       发送前读取UserInfo中的相应信息，并写入
@property (nonatomic,copy) NSString *userNameE;           //英文名            z“新建稿件”       发送前读取UserInfo中的相应信息，并写入
@property (nonatomic,copy) NSString *groupNameC;          //建稿组名（中）     z“新建稿件”       发送前读取UserInfo中的相应信息，并写入
@property (nonatomic,copy) NSString *groupCode;           //建稿组码          z“新建稿件”       发送前读取UserInfo中的相应信息，并写入
@property (nonatomic,copy) NSString *groupNameE;          //建稿组名（英）     z“新建稿件”       发送前读取UserInfo中的相应信息，并写入
@property (nonatomic,copy) NSString *newsType;            //稿件类型          z“新建稿件”       客户端自己定义enum 中文
@property (nonatomic,copy) NSString *newsTypeID;          //稿件类型id        z“新建稿件”       客户端自己定义enum 英文  A/V/T/P
@property (nonatomic,copy) NSString *comment;             //稿件评论            lw“发送”
@property (nonatomic,copy) NSString *rejectTime;          //拒绝时间            lw“发送”
@property (nonatomic,copy) NSString *releTime;            //签发时间            lw“发送”
@property (nonatomic,copy) NSString *sentTime;            //发送时间           z“新建稿件”       发送前写入
@property (nonatomic,copy) NSString *rereleTime;          //重发时间            lw“发送”
@property (nonatomic,copy) NSString *contents;            //稿件正文           z“新建稿件”
@property (nonatomic,copy) NSString *contents3T;          //                  -----
@property (nonatomic,copy) NSString *receiveTime;         //接收时间                            由接收方生成
@property (nonatomic,copy) NSString *newsIDBackTime;      //稿件回传时间         lw
@property (nonatomic,copy) NSString *manuscriptsStatus;   //稿件当前状态         z（保存） lw(发送 接收回传）
@property (nonatomic,strong) ManuscriptTemplate *mTemplate; //稿签信息             z
@property (nonatomic,copy) NSString *location;            //客户端发稿地理位置     z               lw确认格式
@property (nonatomic,copy) NSString *createTime;//


@end
