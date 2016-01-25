//
//  User.h
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

@property (nonatomic,assign) NSInteger u_id;
@property (nonatomic,copy) NSString *loginName;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *userNameC;
@property (nonatomic,copy) NSString *userNameE;
@property (nonatomic,copy) NSString *groupNameC;
@property (nonatomic,copy) NSString *groupNameE;
@property (nonatomic,copy) NSString *groupCode;
@property (nonatomic,copy) NSString *rightDisabled;
@property (nonatomic,copy) NSString *rightSendNews;
@property (nonatomic,copy) NSString *rightReleNews;
@property (nonatomic,copy) NSString *rightTransferNews;
@property (nonatomic,copy) NSArray  *sendAdressList;
@property (nonatomic,copy) NSString *rightAuditNews;


@end
