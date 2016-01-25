//
//  ServerAddressDB.h
//  CNewsPro
//
//  Created by zyq on 16/1/15.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@class ServerAddress;
@interface ServerAddressDB : BasicDatabase

- (ServerAddress *)getDefaultServer;

@end
