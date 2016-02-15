//
//  AppDelegate.m
//  CNewsPro
//
//  Created by zyq on 15/12/28.
//  Copyright © 2015年 BGXT. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "XinHuaManuscriptController.h"
#import "Utility.h"
#import "LoginViewController.h"
#import "RequestMaker.h"
#import "UploadManager.h"
#import "UploadClient.h"
#import "SVProgressHUD.h"
#import "UserGuideViewController.h"
#import <iflyMSC/iflyMSC.h>

@interface AppDelegate () <UIAlertViewDelegate>
@property (nonatomic,strong) UINavigationController *navi;
@property (nonatomic,strong) AVAudioPlayer *headMusicPlayer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self checkVersionGCD];
    
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APP_ID];
    [IFlySpeechUtility createUtility:initString];
    
    [NSTimer scheduledTimerWithTimeInterval:1500.0 target:self
                                   selector:@selector(keepAliveTimer)
                                   userInfo:nil
                                    repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:600.0
                                     target:self
                                   selector:@selector(checkNetwork)
                                   userInfo:nil
                                    repeats:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];

    
    if (![USERDEFAULTS boolForKey:@"firstLaunch"])
    {
        [USERDEFAULTS setBool:YES forKey:@"firstLaunch"];
        UserGuideViewController *userGuideViewController=[[UserGuideViewController alloc] init];
        self.window.rootViewController = userGuideViewController;
    } else {
        XinHuaManuscriptController *xinHuaVC = [[XinHuaManuscriptController alloc]
                                                initWithNibName:@"XinHuaManuscriptController" bundle:nil];
        self.navi = [[UINavigationController alloc] initWithRootViewController:xinHuaVC];
        self.window.rootViewController = self.navi;
    }
    
    [self.window makeKeyAndVisible];
    
    [self initializeBySetting];
    [self playing];
    
    return YES;
}

#pragma mark - Private
/**
 *  非主线程中检查软件版本
 */
- (void)checkVersionGCD {
    __block BOOL isAlert = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([Utility testConnection]) {
            isAlert = [Utility checkNewVersion];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isAlert) {
                [[[UIAlertView alloc] initWithTitle:@"版本更新"
                                            message:@"请下载最新版本"
                                           delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"更新", nil] show];
            }
        });
    });
}

/**
 *  初始化设置页面参数
 */
- (void)initializeBySetting {
    
    NSString *userName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    NSString *pwd = [USERDEFAULTS objectForKey:PASSWORD];
    NSString *kfileBlock = [USERDEFAULTS objectForKey:FILE_BLOCK];
    NSString *autoSaveTime = [USERDEFAULTS objectForKey:AUTO_SAVE_TIME];
    NSString *reSendCount = [USERDEFAULTS objectForKey:RE_SEND_COUNT];
    NSString *compress = [USERDEFAULTS objectForKey:COMPRESS];
    NSString *resolution = [USERDEFAULTS objectForKey:RESOLUTION];
    NSString *codeBit = [USERDEFAULTS objectForKey:CODE_BIT];
    
    if (kfileBlock == nil) {
        [USERDEFAULTS setObject:@"128" forKey:FILE_BLOCK];
    }
    if (autoSaveTime == nil) {
        [USERDEFAULTS setObject:@"30" forKey:AUTO_SAVE_TIME];
    }
    if (reSendCount == nil) {
        [USERDEFAULTS setObject:@"5" forKey:RE_SEND_COUNT];
    }
    if (compress == nil) {
        [USERDEFAULTS setObject:@"高" forKey:COMPRESS];
    }
    if (resolution == nil) {
        [USERDEFAULTS setObject:@"640*480" forKey:RESOLUTION];
    }
    if (codeBit == nil) {
        [USERDEFAULTS setObject:@"1000" forKey:CODE_BIT];
    }
    
    if ([Utility testConnection]) {
        if (userName == nil || pwd == nil) {
            [self pushLoginViewController];
        } else {
            NSString *responseStr = [RequestMaker syncLoginWithUerName:userName password:pwd];
            if ([[responseStr componentsSeparatedByString:@"||"] count] > 1) {
                if ([[[responseStr componentsSeparatedByString:@"||"] objectAtIndex:0] isEqualToString:@"0"]) {
                    //登录成功
                    NSString *sessionId = [[responseStr componentsSeparatedByString:@"||"] lastObject];
                    [USERDEFAULTS setObject:sessionId forKey:SESSION_ID];
                    [USERDEFAULTS setObject:userName forKey:LOGIN_NAME];
                    [USERDEFAULTS synchronize];
                    
                    [Utility initializeUserInfo];
                    [NSThread detachNewThreadSelector:@selector(sendTaskToQueue) toTarget:self withObject:nil];
                } else {
                    [self pushLoginViewController];
                }
            } else {
                [self pushLoginViewController];
            }
        }
    } else {
        [self pushLoginViewController];
    }
}

- (void)pushLoginViewController {
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    self.navi.navigationBarHidden = YES;
    [self.navi pushViewController:loginVC animated:NO];
}

- (void)playing {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"mp3"];
    
    self.headMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
    self.headMusicPlayer.numberOfLoops = -1;
    self.headMusicPlayer.volume = 0.0;
    [self.headMusicPlayer prepareToPlay];
    [self.headMusicPlayer play];
}

+ (AppDelegate *)getAppDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)alert:(AlertType)alertType message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (alertType == AlertTypeSuccess) {
            [SVProgressHUD showSuccessWithStatus:message];
        }else if (alertType == AlertTypeError){
            [SVProgressHUD showErrorWithStatus:message];
        }else {
            [SVProgressHUD showInfoWithStatus:message];
        }
    });
}

#pragma mark - Active

- (void)sendTaskToQueue {
    [Utility sendUnFinishedTaskToQueue];
}

- (void)keepAliveTimer {
    //延长session时间
    [RequestMaker keepAlive];
    
   //获取userInfo
    [Utility initializeUserInfo];
}

- (void)checkNetwork {
    if ([Utility testConnection]) {
        for (int i = 0; i < MAX_CLIENT_COUNT; i ++) {
            if (i < [[UploadManager sharedManager] uploadClientCount]) {
                UploadClient *client = [[UploadManager sharedManager] getClientAtIndex:i];
                NSString *clientStatus = [[UploadManager sharedManager] getUploadRequestStatus:client.currentIndexPath];
                //启动还没有开始的任务
                if (![client paused] && ![client running]) {
                    [client startUpload];
                }
                
                //启动刚开始就失败的任务
                if ([client paused] && [client running] && [clientStatus isEqualToString:LAST_FAIL]) {
                    [client startUpload];
                }
                
                //启动暂停的任务
                else if ([client paused] && [client running]) {
                    [[UploadManager sharedManager] continueUploadClientAtQueueIndex:i];
                }
                [NOTIFICATION_CENTER postNotificationName:UPDATE_UPLOAD_PROGRESS_NOTIFICATION object:client];
            }
        }
    }
}

- (void)checkAndGetNewSessionId {
    if (![Utility testConnection]) {
        return;
    }
    
    //session过期
    if (![RequestMaker keepAlive]) {
        //sessionid过期，所有待发稿件需要重新发送
        for (int i = 0; i < MAX_CLIENT_COUNT; i++) {
            if (i < [[UploadManager sharedManager] uploadClientCount]) {
                UploadClient *client = [[UploadManager sharedManager] getClientAtIndex:i];
                client.progress = 0;
                [client.uploadInfo setObject:LAST_FAIL forKey:REQUEST_STATUS];
            }
        }
        NSString *returnStr = [RequestMaker syncLoginWithUerName:[USERDEFAULTS objectForKey:LOGIN_NAME]
                                                        password:[USERDEFAULTS objectForKey:PASSWORD]];
        if ([[returnStr componentsSeparatedByString:@"||"] count] > 1) {
            if ([[[returnStr componentsSeparatedByString:@"||"] objectAtIndex:0] isEqualToString:@"0"]) {
                NSString *sessionId = [[returnStr componentsSeparatedByString:@"||"] lastObject];
                [USERDEFAULTS setObject:sessionId forKey:SESSION_ID];
                [USERDEFAULTS synchronize];
            }
        }
    }
    
    //激活
    if ([[UploadManager sharedManager] uploadClientCount] == 0) {
        return;
    }
    
    [self checkNetwork];

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    if ([USERDEFAULTS objectForKey:SAVE_PASSWORD]) {
        if (![[USERDEFAULTS objectForKey:SAVE_PASSWORD] intValue]) {
            [USERDEFAULTS setObject:nil forKey:PASSWORD];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//重新开始向应用程序传递触摸事件,在用户忽略其他事件时发生。
//与applicationWillResignActive相关。
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [NSThread detachNewThreadSelector:@selector(checkAndGetNewSessionId) toTarget:self withObject:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *iTunesLink = @"https://itunes.apple.com/us/app/xun-mei-wu-xian/id767219089?ls=1&mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }
}

@end
