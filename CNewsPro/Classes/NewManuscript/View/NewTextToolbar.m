//
//  NewTextToolbar.m
//  CNewsPro
//
//  Created by hooper on 3/16/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "NewTextToolbar.h"
#import "NewArticlesToolbarDelegate.h"

@implementation NewTextToolbar

+ (instancetype)newTextToolbar {
    return [[[NSBundle mainBundle] loadNibNamed:@"NewTextToolbar" owner:nil options:nil] lastObject];
}

- (IBAction)recordButtonClicked:(id)sender {
    if ([_textToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:recordButtonDidClicked:)]) {
        [_textToolbarDelegate newArticlesToolbar:self recordButtonDidClicked:sender];
    }
}

- (IBAction)locationButtonClicked:(id)sender {
    if ([_textToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:locationButtonDidClicked:)]) {
        [_textToolbarDelegate newArticlesToolbar:self locationButtonDidClicked:sender];
    }
}

- (IBAction)saveFileButtonClicked:(id)sender {
    if ([_textToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:saveFileButtonDidClicked:)]) {
        [_textToolbarDelegate newArticlesToolbar:self saveFileButtonDidClicked:sender];
    }
}

- (IBAction)closeKeyboardButtonClicked:(id)sender {
    if ([_textToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:closeKeyboardButtonDidClicked:)]) {
        [_textToolbarDelegate newArticlesToolbar:self closeKeyboardButtonDidClicked:sender];
    }
}

@end
