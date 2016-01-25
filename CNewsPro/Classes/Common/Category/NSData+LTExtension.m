//
//  NSData+LTExtension.m
//  CNewsPro
//
//  Created by zyq on 16/1/18.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "NSData+LTExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (LTExtension)

- (NSString *)MD5 {
    unsigned char result[6];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
