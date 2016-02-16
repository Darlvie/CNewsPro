//
//  SendToAddressDB.h
//  CNewsPro
//
//  Created by hooper on 1/23/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "BasicDatabase.h"

@interface SendToAddressDB : BasicDatabase

/**
 *  查看发稿地址列表
 */
- (NSMutableArray *)getSendToAddressList;

- (BOOL)deleteAll;

- (NSInteger)addSendAddressList:(NSMutableArray*)sendAddressList;






@end
