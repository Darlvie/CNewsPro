//
//  ManuscriptTemplate.m
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "ManuscriptTemplate.h"

static NSString    *kTemplateKey1  =  @"TemplateKey1";
static NSString    *kTemplateKey2  =  @"TemplateKey2";
static NSString    *kTemplateKey3  =  @"TemplateKey3";
static NSString    *kTemplateKey4  =  @"TemplateKey4";
static NSString    *kTemplateKey5  =  @"TemplateKey5";
static NSString    *kTemplateKey6  =  @"TemplateKey6";
static NSString    *kTemplateKey7  =  @"TemplateKey7";
static NSString    *kTemplateKey8  =  @"TemplateKey8";
static NSString    *kTemplateKey9  =  @"TemplateKey9";
static NSString    *kTemplateKey10 =  @"TemplateKey10";
static NSString    *kTemplateKey11 =  @"TemplateKey11";
static NSString    *kTemplateKey12 =  @"TemplateKey12";
static NSString    *kTemplateKey13 =  @"TemplateKey13";
static NSString    *kTemplateKey14 =  @"TemplateKey14";
static NSString    *kTemplateKey15 =  @"TemplateKey15";
static NSString    *kTemplateKey16 =  @"TemplateKey16";
static NSString    *kTemplateKey17 =  @"TemplateKey17";
static NSString    *kTemplateKey18 =  @"TemplateKey18";
static NSString    *kTemplateKey19 =  @"TemplateKey19";
static NSString    *kTemplateKey20 =  @"TemplateKey20";
static NSString    *kTemplateKey21 =  @"TemplateKey21";
static NSString    *kTemplateKey22 =  @"TemplateKey22";
static NSString    *kTemplateKey23 =  @"TemplateKey23";
static NSString    *kTemplateKey24 =  @"TemplateKey24";
static NSString    *kTemplateKey25 =  @"TemplateKey25";
static NSString    *kTemplateKey26 =  @"TemplateKey26";
static NSString    *kTemplateKey27 =  @"TemplateKey27";
static NSString    *kTemplateKey28 =  @"TemplateKey28";
static NSString    *kTemplateKey29 =  @"TemplateKey29";


@implementation ManuscriptTemplate

- (instancetype)init {
    if (self = [super init]) {
        _mt_id=@"";
        _name = @"";
        _loginName=@"";
        _comeFromDept=@"";
        _comeFromDeptID=@"";
        _region = @"";
        _regionID = @"";
        _docType = @"";
        _docTypeID = @"";
        _provType=@"";
        _provTypeid=@"";
        _keywords=@"";
        _language=@"";
        _languageID=@"";
        _priority=@"";
        _priorityID=@"";
        _sendArea=@"";
        _happenPlace=@"";
        _reportPlace=@"";
        _address=@"";
        _addressID=@"";
        _is3Tnews=@"";
        _isDefault = @"";
        _createTime=@"";
        _reviewStatus = @"";
        _defaultTitle = @"";
        _defaultContents = @"";
        _isSystemOriginal = @"";
        _author = @"";
    }
    return self;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.mt_id forKey:kTemplateKey1];
    [encoder encodeObject:self.name forKey:kTemplateKey2];
    [encoder encodeObject:self.loginName forKey:kTemplateKey3];
    [encoder encodeObject:self.comeFromDept forKey:kTemplateKey4];
    [encoder encodeObject:self.comeFromDeptID forKey:kTemplateKey5];
    [encoder encodeObject:self.region forKey:kTemplateKey6];
    [encoder encodeObject:self.regionID forKey:kTemplateKey7];
    [encoder encodeObject:self.docType forKey:kTemplateKey8];
    [encoder encodeObject:self.docTypeID forKey:kTemplateKey9];
    [encoder encodeObject:self.provType forKey:kTemplateKey10];
    [encoder encodeObject:self.provTypeid forKey:kTemplateKey11];
    [encoder encodeObject:self.keywords forKey:kTemplateKey12];
    [encoder encodeObject:self.language forKey:kTemplateKey13];
    [encoder encodeObject:self.languageID forKey:kTemplateKey14];
    [encoder encodeObject:self.priority forKey:kTemplateKey15];
    [encoder encodeObject:self.priorityID forKey:kTemplateKey16];
    [encoder encodeObject:self.sendArea forKey:kTemplateKey17];
    [encoder encodeObject:self.happenPlace forKey:kTemplateKey18];
    [encoder encodeObject:self.reportPlace forKey:kTemplateKey19];
    [encoder encodeObject:self.address forKey:kTemplateKey20];
    [encoder encodeObject:self.addressID forKey:kTemplateKey21];
    [encoder encodeObject:self.is3Tnews forKey:kTemplateKey22];
    [encoder encodeObject:self.isDefault forKey:kTemplateKey23];
    [encoder encodeObject:self.createTime forKey:kTemplateKey24];
    [encoder encodeObject:self.reviewStatus forKey:kTemplateKey25];
    [encoder encodeObject:self.defaultTitle forKey:kTemplateKey26];
    [encoder encodeObject:self.defaultContents forKey:kTemplateKey27];
    [encoder encodeObject:self.isSystemOriginal forKey:kTemplateKey28];
    [encoder encodeObject:self.author forKey:kTemplateKey29];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.mt_id = [decoder decodeObjectForKey:kTemplateKey1];
        self.name = [decoder decodeObjectForKey:kTemplateKey2];
        self.loginName = [decoder decodeObjectForKey:kTemplateKey3];
        self.comeFromDept = [decoder decodeObjectForKey:kTemplateKey4];
        self.comeFromDeptID = [decoder decodeObjectForKey:kTemplateKey5];
        self.region = [decoder decodeObjectForKey:kTemplateKey6];
        self.regionID = [decoder decodeObjectForKey:kTemplateKey7];
        self.docType = [decoder decodeObjectForKey:kTemplateKey8];
        self.docTypeID = [decoder decodeObjectForKey:kTemplateKey9];
        self.provType = [decoder decodeObjectForKey:kTemplateKey10];
        self.provTypeid = [decoder decodeObjectForKey:kTemplateKey11];
        self.keywords = [decoder decodeObjectForKey:kTemplateKey12];
        self.language = [decoder decodeObjectForKey:kTemplateKey13];
        self.languageID = [decoder decodeObjectForKey:kTemplateKey14];
        self.priority = [decoder decodeObjectForKey:kTemplateKey15];
        self.priorityID = [decoder decodeObjectForKey:kTemplateKey16];
        self.sendArea = [decoder decodeObjectForKey:kTemplateKey17];
        self.happenPlace = [decoder decodeObjectForKey:kTemplateKey18];
        self.reportPlace = [decoder decodeObjectForKey:kTemplateKey19];
        self.address = [decoder decodeObjectForKey:kTemplateKey20];
        self.addressID = [decoder decodeObjectForKey:kTemplateKey21];
        self.is3Tnews = [decoder decodeObjectForKey:kTemplateKey22];
        self.isDefault = [decoder decodeObjectForKey:kTemplateKey23];
        self.createTime = [decoder decodeObjectForKey:kTemplateKey24];
        self.reviewStatus = [decoder decodeObjectForKey:kTemplateKey25];
        self.defaultTitle = [decoder decodeObjectForKey:kTemplateKey26];
        self.defaultContents = [decoder decodeObjectForKey:kTemplateKey27];
        self.isSystemOriginal = [decoder decodeObjectForKey:kTemplateKey28];
       self.author = [decoder decodeObjectForKey:kTemplateKey29];
    }
    return self;
}
#pragma mark -
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
    ManuscriptTemplate *copy = [[[self class] allocWithZone: zone] init];
    return copy;
}


@end
