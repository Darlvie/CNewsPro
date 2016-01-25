//
//  RootViewController.h
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEIGH_TO_FMAIN_VIEW(height1,height2,height3) height1-height2-height3

typedef NS_ENUM(NSUInteger,AlertType) {
    AlertTypeSuccess,
    AlertTypeError,
    AlertTypeAlert
};


@interface RootViewController : UIViewController

@property (nonatomic,strong) UIButton *titleLabelAndImage;

@property (nonatomic,strong) UIButton *leftButton;

@property (nonatomic,strong) UIButton *rightButton;

@property (nonatomic,assign) float heightOfMainView;

@property (nonatomic,assign) float widthOfMainView;

- (void)returnToParentView:(UIButton *)button;

- (void)rightButtonPressed:(UIButton *)button;

- (BOOL)connectedToNetwork;

- (void)showAlertWithType:(AlertType)type withString:(NSString *)string;

- (void)showWait;

- (void)hideWaiting;



@end
