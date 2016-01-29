//
//  EmployeeSendToAddress.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmployeeSendToAddress : NSObject

@property (nonatomic,assign) NSInteger esa_id;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *loginName;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *language;
@property (nonatomic,copy) NSString *order;
@property (nonatomic,copy) NSString *type;

@end
