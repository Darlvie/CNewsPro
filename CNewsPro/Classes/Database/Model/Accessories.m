//
//  Accessories.m
//  CNewsPro
//
//  Created by hooper on 1/22/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "Accessories.h"

@implementation Accessories

- (instancetype)init {
    if (self = [super init]) {
        self.a_id = @"";
        self.m_id = @"";
        self.createTime = @"";
        self.title = @"";
        self.desc = @"";
        self.size = @"";
        self.type = @"";
        self.originName = @"";
        self.info = @"";
    }
    return self;
}

@end
