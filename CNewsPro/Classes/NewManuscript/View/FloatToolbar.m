//
//  FloatToolbar.m
//  CNewsPro
//
//  Created by hooper on 3/15/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "FloatToolbar.h"
#import "NewArticlesToolbarDelegate.h"

@implementation FloatToolbar

+ (instancetype)floatToolbar {
    return [[[NSBundle mainBundle] loadNibNamed:@"FloatToolbar" owner:nil options:nil] lastObject];
}

- (IBAction)recordButtonClicked:(id)sender {
    if ([_floatToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:recordButtonDidClicked:)]) {
        [_floatToolbarDelegate newArticlesToolbar:self recordButtonDidClicked:sender];
    }
}

- (IBAction)videoCaptureButtonClicked:(id)sender {
    if ([_floatToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:videoCaptureButtonDidClicked:)]) {
        [_floatToolbarDelegate newArticlesToolbar:self videoCaptureButtonDidClicked:sender];
    }
}

- (IBAction)imageCaptureButtonClicked:(id)sender {
    if ([_floatToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:imageCaptureButtonDidClicked:)]) {
        [_floatToolbarDelegate newArticlesToolbar:self imageCaptureButtonDidClicked:sender];
    }
}

- (IBAction)mediaLibraryButtonClicked:(id)sender {
    if ([_floatToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:mediaLibraryButtonDidClicked:)]) {
        [_floatToolbarDelegate newArticlesToolbar:self mediaLibraryButtonDidClicked:sender];
    }
}

- (IBAction)closeKeyboardButtonClicked:(id)sender {
    if ([_floatToolbarDelegate respondsToSelector:@selector(newArticlesToolbar:closeKeyboardButtonDidClicked:)]) {
        [_floatToolbarDelegate newArticlesToolbar:self closeKeyboardButtonDidClicked:sender];
    }
}

@end
