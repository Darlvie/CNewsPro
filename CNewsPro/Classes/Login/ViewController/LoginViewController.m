//
//  LoginViewController.m
//  CNewsPro
//
//  Created by zyq on 16/1/14.
//  Copyright © 2016年 BGXT. All rights reserved.
//

#import "LoginViewController.h"
#import "Utility.h"
#import "UserDB.h"
#import "User.h"
#import "RequestMaker.h"
#import "AppDelegate.h"
#import "BasicInfoUtility.h"
#import "LoginManagermentController.h"
#import "ManuscriptTemplateDB.h"
#import "ManuscriptTemplate.h"

static const CGFloat kTextWidth = 255;
static const CGFloat kTextHeight = 71;
static const CGFloat kDown = 110;

@interface LoginViewController () <UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UIButton *logoButton;

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong) UITextField *textUserName;

@property (nonatomic,strong) UITextField *textPassword;

@property (nonatomic,assign) NSInteger loginStatus;

@property (nonatomic,assign) BOOL IMEIisRegistered;

@property (nonatomic,strong) UIButton *loginButton;

@property (nonatomic,assign) CGRect originFrame;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.leftButton.userInteractionEnabled = NO;
    self.leftButton.hidden = YES;
    
    self.view.backgroundColor = [UIColor colorWithWhite:243.0/255.0 alpha:1];
    
    self.logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.logoButton.userInteractionEnabled = NO;
    self.logoButton.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabelAndImage.frame) + 44.0, self.widthOfMainView, 60.0);
    [self.logoButton setImage:[UIImage imageNamed:@"login_logo"] forState:UIControlStateNormal];
    [self.logoButton setTitle:@"迅媒无限" forState:UIControlStateNormal];
    [self.logoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.logoButton.titleLabel.font = [UIFont systemFontOfSize:26.0];
    [self.view addSubview:self.logoButton];
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(37, 200, kTextWidth, kTextHeight)];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 27)];
    userNameLabel.text = @"用户名:";
    [userNameLabel setFont:[UIFont fontWithName:@"黑体-简 细体" size:16.0]];
    userNameLabel.backgroundColor = [UIColor clearColor];
    [self.backView addSubview:userNameLabel];
    
    self.textUserName = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userNameLabel.frame), CGRectGetMinY(userNameLabel.frame), kTextWidth - CGRectGetMaxX(userNameLabel.frame), CGRectGetHeight(userNameLabel.frame))];
    self.textUserName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.textUserName setFont:[UIFont fontWithName:@"黑体-简 细体" size:12.0]];
    self.textUserName.delegate = self;
    self.textUserName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textUserName.returnKeyType = UIReturnKeyNext;
    self.textUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.backView addSubview:self.textUserName];
    
    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userNameLabel.frame), kTextWidth, 1)];
    separateLine.backgroundColor = RGBA(236.f, 236.f, 236.f, 1);
    [self.backView addSubview:separateLine];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(userNameLabel.frame), CGRectGetHeight(self.backView.frame)-CGRectGetHeight(userNameLabel.frame), CGRectGetWidth(userNameLabel.frame), CGRectGetHeight(userNameLabel.frame))];
    passwordLabel.text = @"密码:";
    [passwordLabel setFont:[UIFont fontWithName:@"黑体-简 细体" size:16.0]];
    passwordLabel.backgroundColor = [UIColor clearColor];
    [self.backView addSubview:passwordLabel];
    
    self.textPassword = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(passwordLabel.frame), CGRectGetMinY(passwordLabel.frame), CGRectGetWidth(self.textUserName.frame), CGRectGetHeight(self.textUserName.frame))];
    self.textPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.textPassword setFont:[UIFont fontWithName:@"黑体-简 细体" size:12.0]];
    self.textPassword.secureTextEntry = YES;
    self.textPassword.returnKeyType = UIReturnKeyDone;
    self.textPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textPassword.delegate = self;
    [self.backView addSubview:self.textPassword];
    
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(165, self.view.frame.size.height-kDown, 135, 35)];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"loginbtn"] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, self.view.frame.size.height-kDown, 133, 35)];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"SystemSet"] forState:UIControlStateNormal];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn.titleLabel setBackgroundColor:[UIColor clearColor]];
    settingBtn.titleLabel.font = [UIFont fontWithName:@"System" size:15.0 ];
    [settingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(loginMangermentSet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    
    
    NSString *uName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    NSString *pwd = [USERDEFAULTS objectForKey:PASSWORD];
    self.textUserName.text = @"";
    self.textPassword.text = @"";
    if (uName) {
        self.textUserName.text = uName;
    }
    
    if (pwd) {
        self.textPassword.text = pwd;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NOTIFICATION_CENTER addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [NOTIFICATION_CENTER addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.originFrame = self.backView.frame;
}

- (void)dealloc {
    [NOTIFICATION_CENTER removeObserver:self];
}

#pragma mark - Notification
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGFloat keyboardHeight = [value CGRectValue].size.height;
    
    if ((CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.backView.frame)) > keyboardHeight) {
        return;
    } else {
        NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView beginAnimations:@"ResizeView" context:nil];
        [UIView setAnimationDuration:duration];
        
        CGRect tempFrame = self.originFrame;
        tempFrame.origin.y -= 64;
        self.backView.frame = tempFrame;
        self.logoButton.alpha = 0.3;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.backView.frame = self.originFrame;
    self.logoButton.alpha = 1.0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Action
- (void)loginAction:(id)sender {
    if ([self.textUserName.text isEqualToString:@""]) {
        [self showAlertWithType:AlertTypeAlert withString:@"请输入用户名"];
        return;
    } else if ([self.textPassword.text isEqualToString:@""]) {
        [self showAlertWithType:AlertTypeAlert withString:@"请输入密码"];
        return;
    }
    
    [NSThread detachNewThreadSelector:@selector(showWait) toTarget:self withObject:nil];
    if (![Utility testConnection]) {
        UserDB *userDB = [[UserDB alloc] init];
        //检测是否可以离线登录
        if ([userDB getUserAndPassword:self.textUserName.text password:self.textPassword.text]) {
            //创建用户文件夹
            [self createFile];
            //离线登录的情况下，从文件中读取userinfo的信息
            [Utility getUserInfoFromFile];
            [USERDEFAULTS setObject:@"" forKey:SESSION_ID];
            [USERDEFAULTS setObject:self.textUserName.text forKey:LOGIN_NAME];
            [USERDEFAULTS setObject:self.textPassword.text forKey:PASSWORD];
            [USERDEFAULTS synchronize];
            
            [[AppDelegate getAppDelegate] alert:AlertTypeSuccess message:@"当前网络不佳，您已离线登录!"];
            [Utility sendUnFinishedTaskToQueue];
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            [[AppDelegate getAppDelegate] alert:AlertTypeAlert message:@"第一次登录请连接网络"];
        }
        [self hideWaiting];
        return;
    }
    [RequestMaker loginWithUsername:self.textUserName.text password:self.textPassword.text delegate:self];
}

- (void)loginMangermentSet:(id)sender {
    LoginManagermentController *vc = [[LoginManagermentController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)createFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *paths = [self getPath];
    if (![fileManager fileExistsAtPath:paths]) {
        [fileManager createDirectoryAtPath:paths withIntermediateDirectories:YES attributes:nil error:nil];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (NSString *)getPath {
    NSString *docDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [docDirectory stringByAppendingPathComponent:[USERDEFAULTS objectForKey:LOGIN_NAME]];
}

//网络回调
- (void)requestDidFinish:(NSDictionary *)responseInfo {
    NSData *responseData = [responseInfo objectForKey:RESPONSE_DATA];
    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    if (![[responseInfo objectForKey:REQUEST_STATUS] isEqualToString:REQUEST_SUCCESS]) {
        [self hideWaiting];
        [[AppDelegate getAppDelegate] alert:AlertTypeError message:[responseInfo objectForKey:@"responseError"]];
        return;
    }
    
    if ([responseStr componentsSeparatedByString:@"||"].count > 1) {
        //成功登录
        if ([[[responseStr componentsSeparatedByString:@"||"] objectAtIndex:0] isEqualToString:@"0"]) {
            NSString *sessionId = [[responseStr componentsSeparatedByString:@"||"] lastObject];
            [USERDEFAULTS setObject:sessionId forKey:SESSION_ID];
            [USERDEFAULTS setObject:self.textUserName.text forKey:LOGIN_NAME];
            [USERDEFAULTS setObject:self.textPassword.text forKey:PASSWORD];
            [USERDEFAULTS synchronize];
            
            //创建用户文件
            [self createFile];
            //同步获取userInfo
            [Utility InitializeUserInfo];
            
            //检测登录用户名是否拥有系统稿签，如无则为其自动添加
            [self addSystemTemplate];
            
            UserDB *userDB = [[UserDB alloc] init];
            if (![userDB getUserAndPassword:self.textUserName.text password:self.textPassword.text]) {
                User *userInfo = [[User alloc] init];
                userInfo.loginName = self.textUserName.text;
                userInfo.password = self.textPassword.text;
                [userDB addUser:userInfo];
            }
            [Utility sendUnFinishedTaskToQueue];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self updateBasicData];
        } else {
            //登录失败
            if ([responseStr componentsSeparatedByString:@"||"].count > 1) {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:[[responseStr componentsSeparatedByString:@"||"] objectAtIndex:1]
                                           delegate:self
                                  cancelButtonTitle:@"确认"
                                  otherButtonTitles:nil, nil] show];
                self.IMEIisRegistered = NO;
            } else {
                [[AppDelegate getAppDelegate] alert:AlertTypeError message:[responseInfo objectForKey:@"responseError"]];
            }
        }
    } else {
        if ([responseStr componentsSeparatedByString:@"||"].count > 1) {
            [[AppDelegate getAppDelegate] alert:AlertTypeAlert
                                        message:[[responseStr componentsSeparatedByString:@"||"] objectAtIndex:1]];
            
        }else {
            //登录失败，检查是否可以离线登录
            UserDB *userDB = [[UserDB alloc] init];
            if ([userDB getUserAndPassword:self.textUserName.text password:self.textPassword.text]) {
                [self createFile];
                [Utility InitializeUserInfo];
                [USERDEFAULTS setObject:@"" forKey:SESSION_ID];
                [USERDEFAULTS setObject:self.textUserName.text forKey:LOGIN_NAME];
                [USERDEFAULTS setObject:self.textPassword.text forKey:PASSWORD];
                [Utility sendUnFinishedTaskToQueue];
                [self.navigationController popToRootViewControllerAnimated:NO];
            } else {
                [[AppDelegate getAppDelegate] alert:AlertTypeError
                                            message:[responseInfo objectForKey:@"responseError"]];
            }
        }
    }
    [self hideWaiting];
}

//更新基础数据
- (void)updateBasicData {
    BasicInfoUtility *basicInfo = [[BasicInfoUtility alloc] init];
    //拷贝存放基础数据的plist文件
    if ([basicInfo copyBasicInfoPlist]) {
        NSString *xmlFileNameList = [basicInfo getFileNameList];
        //查看基础数据是否有更新
        NSString *xmlResult = [basicInfo getFileNameWithNewBasicInfo:xmlFileNameList];
        if ([xmlResult isEqualToString:@""] || [xmlResult isEqual:nil]) {
            NSLog(@"没有可更新的数据或者网络不响应");
        } else {
            [basicInfo updateBasicInfo:xmlResult];
        }
    } else {
        NSLog(@"拷贝plist文件失败");
    }
}

//检测登录用户名是否拥有系统稿签，如无则为其自动添加
- (BOOL)addSystemTemplate {
    NSString *loginName = [USERDEFAULTS objectForKey:LOGIN_NAME];
    ManuscriptTemplateDB *checkManuscriptTemplateDB = [[ManuscriptTemplateDB alloc] init];
    
    if (![[checkManuscriptTemplateDB getSystemTemplate:loginName type:MANUSCRIPT_TEMPLATE_TYPE] count]) {
        //将服务器上的稿签同步到手机
        [Utility getTemplate];
        NSArray *sysArray = [[NSArray alloc] initWithObjects:@"文字快讯",@"音频快讯",@"视频快讯",@"图片快讯",nil];
        NSArray *templateTypeArray = [[NSArray alloc] initWithObjects:TEXT_EXPRESS_TEMPLATE_TYPE,AUDIO_EXPRESS_TEMPLATE_TYPE,PICTURE_EXPRESS_TEMPLATE_TYPE,VIDEO_EXPRESS_TEMPLATE_TYPE, nil];
        for (int i = 0; i < 4; i++) {
            ManuscriptTemplate *manuscriptTemplate = [[ManuscriptTemplate alloc] init];
            manuscriptTemplate.mt_id = [Utility stringWithUUID];
            manuscriptTemplate.is3Tnews = @"0";//是否3T稿件
            manuscriptTemplate.isDefault = @"0";//是否默认稿签
            manuscriptTemplate.createTime = [Utility getLogTimeStamp];
            manuscriptTemplate.isSystemOriginal = [templateTypeArray objectAtIndex:i];//@"1";//是否系统稿签
            manuscriptTemplate.name = [sysArray objectAtIndex:i];
            manuscriptTemplate.loginName = loginName;
            [checkManuscriptTemplateDB addManuscriptTemplate:manuscriptTemplate];
        }
    }
    return TRUE;
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.IMEIisRegistered) {
        return;
    }
    [RequestMaker loginWithUsername:self.textUserName.text password:self.textPassword.text delegate:self];
    [Utility checkVersion];//保存最低版本号
}

















@end
