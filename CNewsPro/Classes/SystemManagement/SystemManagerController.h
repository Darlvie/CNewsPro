//
//  SystemManagerController.h
//  CNewsPro
//
//  Created by hooper on 1/28/16.
//  Copyright © 2016 BGXT. All rights reserved.
//

#import "RootViewController.h"

@interface SystemManagerController : RootViewController
/** 网络设置项 **/
@property (strong,nonatomic) NSArray *networkSettingItems;
/** 本地设置项 **/
@property (strong,nonatomic) NSArray *localSettingItems;

@property (strong,nonatomic) UITableView *sysTableView;
/** 当前用户 **/
@property (copy,nonatomic) NSString *currentuser;
/** 当前版本 **/
@property (copy,nonatomic) NSString *currentversion;
/** 当前服务器 **/
@property (copy,nonatomic) NSString *currentserver;
/** 传输文件块大小 **/
@property (copy,nonatomic) NSString *currentFileBlock;
/** 压缩情况 **/
@property (copy,nonatomic) NSString *compress;
/** 公用动作表 **/
@property (strong,nonatomic) UIView *actionSheet;
/** 供选择的传输文件块大小 **/
@property (strong,nonatomic) NSArray *fileBlockArray;

@property (copy,nonatomic) NSString *currentAutoSaveTime;
/** 供选择的自动保存时间 **/
@property (strong,nonatomic) NSArray *autoSaveTimeArray;
/** 设置是否保存密码的开关 **/
@property (strong,nonatomic) UISwitch *switchOfSavePassword;
/** 自动重传次数 **/
@property (strong,nonatomic) NSArray *autoReSendCount;
/** 重传次数 **/
@property (copy,nonatomic) NSString *currentResendCount;
/** 压缩 **/
@property (strong,nonatomic) NSArray *compressLevel;
/** 分辨率设置 **/
@property (strong,nonatomic) NSArray *resolutionArry;
/** 分辨率 **/
@property (copy,nonatomic) NSString *resolution;
/** 码率 **/
@property (strong,nonatomic) NSArray *codeBitArray;
/** 当前码率 **/
@property (copy,nonatomic) NSString *codeText;

@end
