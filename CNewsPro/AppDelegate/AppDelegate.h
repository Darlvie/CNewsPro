//
//  AppDelegate.h
//  CNewsPro
//
//  Created by zyq on 15/12/28.
//  Copyright © 2015年 BGXT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *)getAppDelegate;

- (void)alert:(AlertType)alertType message:(NSString *)message;

@end

