//
//  SendToAddressController.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"


typedef NS_ENUM(NSInteger,SendToAddressType) {
    SendToAddressTypeCustom,
    SendToAddressTypeSelectCustom,
    SendToAddressTypeNoCustom
};

@interface SendToAddressController : RootViewController

@property (nonatomic,assign) NSInteger sendToAddressType;
@property (nonatomic,strong) NSMutableArray *sendToAddressArray;
@property (nonatomic,strong) NSArray *selectedSendToAddressArray;
@property (nonatomic,strong) NSMutableDictionary *sendToAddressDictionary;
@property (nonatomic,strong) UITableView *sendToAddressView;
@end
