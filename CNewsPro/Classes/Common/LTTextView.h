//
//  LTTextView.h
//  LT_微博
//
//  Created by aUser on 9/1/15.
//  Copyright (c) 2015 aUser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTTextView : UITextView
/** 占位文字 */
@property (nonatomic,copy) NSString *placeholder;
/** 占位文字颜色 */
@property (nonatomic,strong) UIColor *placeholderColor;
@end
