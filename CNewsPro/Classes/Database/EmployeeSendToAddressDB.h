//
//  EmployeeSendToAddressDB.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@class EmployeeSendToAddress;
@interface EmployeeSendToAddressDB : BasicDatabase

- (NSInteger)addESTAddress:(EmployeeSendToAddress*)estAddress;

- (NSMutableArray*)getESTAddressListLoginName:(NSString*)loginName;

- (BOOL)deleteAll;

@end
