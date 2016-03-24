//
//  NewTextToolbar.h
//  CNewsPro
//
//  Created by hooper on 3/16/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  NewArticlesToolbarDelegate;

@interface NewTextToolbar : UIToolbar

@property (nonatomic,weak) id<NewArticlesToolbarDelegate> textToolbarDelegate;

+ (instancetype)newTextToolbar;

@end
