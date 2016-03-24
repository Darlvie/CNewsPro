//
//  FloatToolbar.h
//  CNewsPro
//
//  Created by hooper on 3/15/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  NewArticlesToolbarDelegate;

@interface FloatToolbar : UIToolbar

@property (nonatomic,weak) id<NewArticlesToolbarDelegate> floatToolbarDelegate;

+ (instancetype)floatToolbar;

@end
