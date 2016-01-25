//
//  User.m
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "User.h"

static NSString*    kLoginName  =  @"loginname";
static NSString*    kPassword   =  @"password";
static NSString*    kUserNameC  =  @"usernameC";
static NSString*    kUserNameE  =  @"usernameE";
static NSString*    kGroupNameC =  @"groupnameC";
static NSString*    kGroupNameE =  @"groupnameE";
static NSString*    kGroupCode  =  @"groupcode";
static NSString*    kRightDisabled  = @"RightDisabled";
static NSString*    kRightSendNews  =  @"RightSendNews";
static NSString*    kRightReleNews  =  @"RightReleNews";
static NSString*    kRightTransferNews  =  @"RightTransferNews";
static NSString*    kSendAdressList  =  @"SendAdressList";
static NSString*    kRightAuditNews  =  @"AuditNews";

@implementation User

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.loginName forKey:kLoginName];
    [encoder encodeObject:self.password forKey:kPassword];
    [encoder encodeObject:self.userNameC forKey:kUserNameC];
    [encoder encodeObject:self.userNameE forKey:kUserNameE];
    [encoder encodeObject:self.groupNameC forKey:kGroupNameC];
    [encoder encodeObject:self.groupNameE forKey:kGroupNameE];
    [encoder encodeObject:self.groupCode forKey:kGroupCode];
    [encoder encodeObject:self.rightDisabled forKey:kRightDisabled];
    [encoder encodeObject:self.rightSendNews forKey:kRightSendNews];
    [encoder encodeObject:self.rightReleNews forKey:kRightReleNews];
    [encoder encodeObject:self.rightTransferNews forKey:kRightTransferNews];
    [encoder encodeObject:self.sendAdressList forKey:kSendAdressList];
    [encoder encodeObject:self.rightAuditNews forKey:kRightAuditNews];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.loginName = [decoder decodeObjectForKey:kLoginName];
        self.password = [decoder decodeObjectForKey:kPassword];
        self.userNameC = [decoder decodeObjectForKey:kUserNameC];
        self.userNameE = [decoder decodeObjectForKey:kUserNameE];
        self.groupNameC = [decoder decodeObjectForKey:kGroupNameC];
        self.groupNameE = [decoder decodeObjectForKey:kGroupNameE];
        self.groupCode = [decoder decodeObjectForKey:kGroupCode];
        self.rightDisabled = [decoder decodeObjectForKey:kRightDisabled];
        self.rightSendNews = [decoder decodeObjectForKey:kRightSendNews];
        self.rightReleNews = [decoder decodeObjectForKey:kRightReleNews];
        self.rightTransferNews = [decoder decodeObjectForKey:kRightTransferNews];
        self.sendAdressList = [decoder decodeObjectForKey:kSendAdressList];
        self.rightAuditNews = [decoder decodeObjectForKey:kRightAuditNews];
    }
    return self;
}

@end
