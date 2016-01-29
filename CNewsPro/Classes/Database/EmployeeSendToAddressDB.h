//
//  EmployeeSendToAddressDB.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface EmployeeSendToAddressDB : BasicDatabase

- (NSMutableArray*)getESTAddressListLoginName:(NSString*)loginName;

@end
