//
//  NewTextController.h
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

@interface NewTextController : RootViewController

@property (nonatomic,copy) NSString *manuscript_id;

- (void)textFieldDoneEditing:(id)sender;

@end
