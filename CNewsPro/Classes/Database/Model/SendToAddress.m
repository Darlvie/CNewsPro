//
//  SendToAddress.m
//  CNewsPro
//
//  Created by hooper on 1/23/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "SendToAddress.h"


static NSString *kStaid = @"sta_id";
static NSString *kCode = @"code";
static NSString *kName = @"name";
static NSString *kLanguage = @"language";
static NSString *kOrder =  @"order";

@implementation SendToAddress

- (void)encodeWithCoder:(NSCoder *)encoder {
    //[encoder encodeObject:sta_id forKey:Kstaid];
    [encoder encodeObject:self.code forKey:kCode];
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.language forKey:kLanguage];
    [encoder encodeObject:self.order forKey:kOrder];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        //sta_id = [[decoder decodeObjectForKey:Kstaid] retain];
        self.code = [decoder decodeObjectForKey:kCode];
        self.name = [decoder decodeObjectForKey:kName];
        self.language = [decoder decodeObjectForKey:kLanguage];
        self.order = [decoder decodeObjectForKey:kOrder];
    }
    return self;
}

@end
