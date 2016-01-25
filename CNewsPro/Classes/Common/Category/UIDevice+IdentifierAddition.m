//
//  UIDevice+IdentifierAddition.m
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "UIDevice+IdentifierAddition.h"
#import "OpenUDID.h"
#import "NSString+Security.h"
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>

@implementation UIDevice (IdentifierAddition)

- (NSString *)uniqueGlobalDeviceIdentifier {
    NSString *uniqueIdentifier = @"device error";
    
    float systemVersion = [[[UIDevice currentDevice] systemName] floatValue];
    
    if (systemVersion > 6.9) {
        uniqueIdentifier = [OpenUDID value];
        uniqueIdentifier = [[uniqueIdentifier MD5] substringWithRange:NSMakeRange(6, 16)];
        uniqueIdentifier = [uniqueIdentifier uppercaseString];
    } else {
        NSString *macAddress = [[UIDevice currentDevice] macAddress];
        uniqueIdentifier = [macAddress stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    return uniqueIdentifier;
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *)macAddress {
    int                mib[6];
    size_t             len;
    char               *buf;
    unsigned char      *ptr;
    struct if_msghdr   *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outString;
}

@end
