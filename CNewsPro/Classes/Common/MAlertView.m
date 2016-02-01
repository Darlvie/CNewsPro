//
//  MAlertView.m
//  CNewsPro
//
//  Created by hooper on 2/1/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "MAlertView.h"

static const NSInteger kMAlertViewTextFieldHeight = 30.0;
static const NSInteger kMAlertViewMargin = 10.0;

@interface MAlertView ()
@property (nonatomic,strong) UITextField *passwdField;
@property (nonatomic,assign) NSInteger textFieldCount;
@end

@implementation MAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    if ((self = [super initWithTitle:title
                             message:message
                            delegate:delegate
                   cancelButtonTitle:cancelButtonTitle
                   otherButtonTitles:otherButtonTitles,nil])) {
        self.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    return self;
}

- (void)layoutSubviews{
    
    CGRect rect = self.bounds;
    rect.size.height += self.textFieldCount*(kMAlertViewTextFieldHeight + kMAlertViewMargin);
    self.bounds = rect;
    float maxLabelY = 0.f;
    int textFieldIndex = 0;
    for (UIView *view in self.subviews) {
        
        if ([view isKindOfClass:[UIImageView class]]) {
            
        }
        else if ([view isKindOfClass:[UILabel class]]) {
            
            rect = view.frame;
            maxLabelY = rect.origin.y + rect.size.height;
        }
        else if ([view isKindOfClass:[UITextField class]]) {
            
            rect = view.frame;
            rect.size.width = self.bounds.size.width - 2*kMAlertViewMargin;
            rect.size.height = kMAlertViewTextFieldHeight;
            rect.origin.x = kMAlertViewMargin;
            rect.origin.y = maxLabelY + kMAlertViewMargin*(textFieldIndex+1) + kMAlertViewTextFieldHeight*textFieldIndex;
            view.frame = rect;
            textFieldIndex++;
        }
        else {  //UIThreePartButton
            
            rect = view.frame;
            rect.origin.y = self.bounds.size.height - 65.0;
            view.frame = rect;
        }
    }
    
}

- (void)addTextField:(NSString *)aTextField placeHolder:(NSString *)placeHolder{
    UITextField *textfield = [self textFieldAtIndex:0];
    textfield.text = aTextField;
}

@end
