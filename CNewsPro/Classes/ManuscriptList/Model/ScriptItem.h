//
//  ScriptItem.h
//  CNewsPro
//
//  Created by hooper on 1/27/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "Manuscripts.h"
#import <UIKit/UIKit.h>

@interface ScriptItem : Manuscripts

@property (nonatomic,assign) BOOL checked;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) NSInteger indexPath;

+ (ScriptItem *)scriptItem;

@end
