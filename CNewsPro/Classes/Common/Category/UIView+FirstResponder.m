//
//  UIView+FirstResponder.m
//  CNewsPro
//
//  Created by hooper on 2/2/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "UIView+FirstResponder.h"

@implementation UIView (FirstResponder)

- (UIView *)findFirstResponder
{
    if ([self isFirstResponder]) {
        return self;
    }
    
    for (UIView *subview in [self subviews]) {
        UIView *firstResponder = [subview findFirstResponder];
        if (nil != firstResponder) {
            return firstResponder;
        }
    }
    
    return nil;
}

@end
