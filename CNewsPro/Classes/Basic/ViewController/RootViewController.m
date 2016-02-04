//
//  RootViewController.m
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "RootViewController.h"
#import "Utility.h"
#import "SVProgressHUD.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.widthOfMainView = CGRectGetWidth(self.view.frame);
    
    float deltY = IOS_7? 20.f : 0.f;
    
    self.titleLabelAndImage = [UIButton buttonWithType:UIButtonTypeCustom];
    self.titleLabelAndImage.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44.0 + deltY);
    self.titleLabelAndImage.userInteractionEnabled = NO;
    self.titleLabelAndImage.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:21.0];
    [self.titleLabelAndImage setImageEdgeInsets:UIEdgeInsetsMake(deltY, 0, 0, 0)];
    [self.titleLabelAndImage setTitleEdgeInsets:UIEdgeInsetsMake(deltY, 0, 0, 0)];
    [self.view addSubview:self.titleLabelAndImage];
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.frame = CGRectMake(0, deltY, 44.0, 44.0);
    [self.leftButton setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self
                        action:@selector(returnToParentView:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.frame = CGRectMake(self.widthOfMainView - 44.0, deltY, 44.0, 44.0);
    self.rightButton.userInteractionEnabled = NO;
    [self.view addSubview:self.rightButton];
    
    self.heightOfMainView = HEIGH_TO_FMAIN_VIEW(CGRectGetHeight(self.view.frame), CGRectGetMaxY(self.titleLabelAndImage.frame), 0.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Actions
- (void)returnToParentView:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonPressed:(UIButton *)button {
    
}

#pragma mark -网络
- (BOOL)connectedToNetwork {
    BOOL isReachable = [Utility testConnection];
    return isReachable;
}

#pragma mark -提示
- (void)showAlertWithType:(AlertType)type withString:(NSString *)string {
    if (type == AlertTypeSuccess) {
        [SVProgressHUD showSuccessWithStatus:string];
    } else if (type == AlertTypeError) {
        [SVProgressHUD showErrorWithStatus:string];
    } else if (type == AlertTypeAlert) {
        [SVProgressHUD showInfoWithStatus:string];
    }
}

- (void)showWait {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}

- (void)hideWaiting {
    [SVProgressHUD dismiss];
}








@end
