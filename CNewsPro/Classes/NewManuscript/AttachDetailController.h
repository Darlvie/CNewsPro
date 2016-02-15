//
//  AttachDetailController.h
//  CNewsPro
//
//  Created by hooper on 2/2/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

@class Accessories;
@interface AttachDetailController : RootViewController

@property (nonatomic,copy) NSString *filepath;//附件地址
@property (nonatomic,copy) NSString *filetype;
@property (nonatomic,strong) Accessories *accessory;

- (void)saveAttachDetail:(id)sender;
- (void)textFieldDoneEditing:(id)sender;

@end
