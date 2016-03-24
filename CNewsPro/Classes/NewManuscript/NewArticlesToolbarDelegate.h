//
//  NewArticlesToolbarDelegate.h
//  CNewsPro
//
//  Created by hooper on 3/15/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewArticlesToolbarDelegate <NSObject>

@optional
- (void)newArticlesToolbar:(UIToolbar *)toolbar recordButtonDidClicked:(id)button;
- (void)newArticlesToolbar:(UIToolbar *)toolbar mediaLibraryButtonDidClicked:(id)button;
- (void)newArticlesToolbar:(UIToolbar *)toolbar locationButtonDidClicked:(id)button;
- (void)newArticlesToolbar:(UIToolbar *)toolbar saveFileButtonDidClicked:(id)button;
- (void)newArticlesToolbar:(UIToolbar *)toolbar videoCaptureButtonDidClicked:(id)button;
- (void)newArticlesToolbar:(UIToolbar *)toolbar imageCaptureButtonDidClicked:(id)button;
- (void)newArticlesToolbar:(UIToolbar *)toolbar closeKeyboardButtonDidClicked:(id)button;

@end

