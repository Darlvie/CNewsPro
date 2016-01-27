//
//  ComeFromAddress.h
//  CNewsPro
//
//  Created by hooper on 1/26/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComeFromAddress : NSObject

@property (nonatomic,assign) NSInteger ca_id;
@property (nonatomic,assign) NSInteger checked;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *language;

@end
