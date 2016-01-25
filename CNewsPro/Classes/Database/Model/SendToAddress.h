//
//  SendToAddress.h
//  CNewsPro
//
//  Created by hooper on 1/23/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendToAddress : NSObject <NSCoding>

@property (nonatomic,assign) NSInteger sta_id;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *language;
@property (nonatomic,copy) NSString *order;

@end
