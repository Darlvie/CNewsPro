//
//  FixedToolbar.m
//  CNewsPro
//
//  Created by hooper on 3/15/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "FixedToolbar.h"
#import "NewArticlesToolbarDelegate.h"

@implementation FixedToolbar

+ (instancetype)fixedToolbar {
    return [[[NSBundle mainBundle] loadNibNamed:@"FixedToolbar" owner:nil options:nil] lastObject];
}

- (IBAction)recordButtonClicked:(id)sender {
    if ([_toobarDelegate respondsToSelector:@selector(newArticlesToolbar:recordButtonDidClicked:)]) {
        [_toobarDelegate newArticlesToolbar:self recordButtonDidClicked:sender];
    }
}

- (IBAction)mediaLibraryButtonCliced:(id)sender {
    if ([_toobarDelegate respondsToSelector:@selector(newArticlesToolbar:mediaLibraryButtonDidClicked:)]) {
        [_toobarDelegate newArticlesToolbar:self mediaLibraryButtonDidClicked:sender];
    }
}

- (IBAction)locationButtonClicked:(id)sender {
    if ([_toobarDelegate respondsToSelector:@selector(newArticlesToolbar:locationButtonDidClicked:)]) {
        [_toobarDelegate newArticlesToolbar:self locationButtonDidClicked:sender];
    }
}

- (IBAction)saveFileButtonClicked:(id)sender {
    if ([_toobarDelegate respondsToSelector:@selector(newArticlesToolbar:saveFileButtonDidClicked:)]) {
        [_toobarDelegate newArticlesToolbar:self saveFileButtonDidClicked:sender];
    }
}

@end
